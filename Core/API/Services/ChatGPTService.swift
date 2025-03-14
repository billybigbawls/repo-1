//
//  ChatGPTService.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 11/12/24.
//

import Foundation
import Combine

class ChatGPTService {
    static let shared = ChatGPTService()
    private let secureKeyManager = SecureKeyManager.shared
    
    private var cancellables = Set<AnyCancellable>()
    private let messageCache = NSCache<NSString, NSArray>()
    private var requestsThisMinute = 0
    private var lastRequestTime: Date?
    
    private init() {
        setupRateLimitReset()
    }
    
    // MARK: - Public Methods
    
    func sendMessage(_ message: String,
                    aiPersonality: String,
                    messageHistory: [Message] = [],
                    completion: @escaping (Result<String, Error>) -> Void) {
        
        // Check auth token instead of API key
        guard let authToken = secureKeyManager.getAccessToken() else {
            // Try to refresh the token if we have a refresh token
            if let refreshToken = secureKeyManager.getRefreshToken() {
                refreshAccessToken(refreshToken) { [weak self] result in
                    switch result {
                    case .success:
                        // Token refreshed, retry the message
                        self?.sendMessage(message, aiPersonality: aiPersonality, messageHistory: messageHistory, completion: completion)
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
                return
            } else {
                completion(.failure(APIError.unauthorized))
                return
            }
        }
        
        // Check rate limiting
        guard canMakeRequest() else {
            completion(.failure(APIError.rateLimitExceeded))
            return
        }
        
        // Create request to Squad backend
        let requestSettings = RequestSettings(
            maxTokens: APIConfig.maxTokens,
            temperature: APIConfig.temperature,
            language: Locale.current.languageCode
        )
        
        // Convert aiPersonality string to applicable Squad AI ID or personality type
        let aiId: String? = mapPersonalityToAiId(aiPersonality)
        
        let requestBody = ChatRequest(
            message: message,
            aiId: aiId,
            settings: requestSettings
        )
        
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            completion(.failure(APIError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: URL(string: "\(APIConfig.baseURL)/api/v1/ai/generate")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        // Make request
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 401:
                    // Token expired, try to refresh
                    if let refreshToken = self.secureKeyManager.getRefreshToken() {
                        // Handle this outside of this chain to avoid complexity
                        // We'll throw an error for now and handle refresh at higher level
                        throw APIError.tokenExpired
                    }
                    throw APIError.unauthorized
                case 429:
                    throw APIError.rateLimitExceeded
                default:
                    throw APIError.serverError(httpResponse.statusCode)
                }
            }
            .decode(type: SquadChatResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        if let apiError = error as? APIError, apiError == .tokenExpired {
                            // Handle token refresh and retry
                            if let refreshToken = self.secureKeyManager.getRefreshToken() {
                                self.refreshAccessToken(refreshToken) { [weak self] refreshResult in
                                    switch refreshResult {
                                    case .success:
                                        // Token refreshed, retry the message
                                        self?.sendMessage(message, aiPersonality: aiPersonality, messageHistory: messageHistory, completion: completion)
                                    case .failure(let refreshError):
                                        completion(.failure(refreshError))
                                    }
                                }
                                return
                            }
                        }
                        completion(.failure(error))
                    }
                },
                receiveValue: { response in
                    if let content = response.content {
                        self.cacheResponse(content, for: aiPersonality)
                        completion(.success(content))
                    } else {
                        completion(.failure(APIError.noResponse))
                    }
                }
            )
            .store(in: &cancellables)
        
        incrementRequestCount()
    }
    
    // MARK: - Token Management
    
    private func refreshAccessToken(_ refreshToken: String, completion: @escaping (Result<Void, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "\(APIConfig.baseURL)/api/v1/auth/refresh-token")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = ["refreshToken": refreshToken]
        request.httpBody = try? JSONEncoder().encode(requestBody)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw APIError.unauthorized
                }
                return data
            }
            .decode(type: TokenResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    }
                },
                receiveValue: { response in
                    self.secureKeyManager.saveAccessToken(response.accessToken)
                    if let refreshToken = response.refreshToken {
                        self.secureKeyManager.saveRefreshToken(refreshToken)
                    }
                    completion(.success(()))
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    private func mapPersonalityToAiId(_ personality: String) -> String? {
        // Map the personality string to a Squad AI ID or return nil to use default
        // This would need to be implemented based on the available AIs in the Squad backend
        return nil  // For now, use the default AI
    }
    
    private func truncateHistory(_ messages: [Message]) -> [Message] {
        let recentMessages = messages.suffix(APIConfig.messageHistoryLimit)
        var tokenCount = 0
        
        return recentMessages.filter { message in
            tokenCount += estimateTokenCount(message.content)
            return tokenCount < (APIConfig.tokenLimit / 2)
        }
    }
    
    private func estimateTokenCount(_ text: String) -> Int {
        // Rough estimate: 4 characters per token
        return text.count / 4
    }
    
    private func cacheResponse(_ response: String, for personality: String) {
        let key = NSString(string: "\(personality)_last_response")
        messageCache.setObject([response] as NSArray, forKey: key)
    }
    
    private func setupRateLimitReset() {
        Timer.publish(every: APILimits.cooldownPeriod, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.requestsThisMinute = 0
            }
            .store(in: &cancellables)
    }
    
    private func canMakeRequest() -> Bool {
        if requestsThisMinute >= APILimits.maxRequestsPerMinute {
            return false
        }
        return true
    }
    
    private func incrementRequestCount() {
        requestsThisMinute += 1
        lastRequestTime = Date()
    }
}

// MARK: - Squad-Specific Models

struct ChatRequest: Codable {
    let message: String
    let aiId: String?
    let settings: RequestSettings
}

struct RequestSettings: Codable {
    let maxTokens: Int
    let temperature: Double
    let language: String?
}

struct SquadChatResponse: Codable {
    let content: String?
    let metadata: ResponseMetadata?
}

struct ResponseMetadata: Codable {
    let tokens: Int?
    let processingTime: Double?
    let aiPersonality: String?
    let promptTokens: Int?
    let completionTokens: Int?
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
}

// MARK: - Error Types

enum APIError: Error, Equatable {
    case noAPIKey
    case invalidRequest
    case invalidResponse
    case rateLimitExceeded
    case unauthorized
    case tokenExpired
    case serverError(Int)
    case noResponse
    
    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.noAPIKey, .noAPIKey),
             (.invalidRequest, .invalidRequest),
             (.invalidResponse, .invalidResponse),
             (.rateLimitExceeded, .rateLimitExceeded),
             (.unauthorized, .unauthorized),
             (.tokenExpired, .tokenExpired),
             (.noResponse, .noResponse):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .noAPIKey:
            return "API key not found"
        case .invalidRequest:
            return "Invalid request"
        case .invalidResponse:
            return "Invalid response from server"
        case .rateLimitExceeded:
            return "Too many requests. Please wait a moment."
        case .unauthorized:
            return "Unauthorized. Please check your credentials."
        case .tokenExpired:
            return "Session expired. Please log in again."
        case .serverError(let code):
            return "Server error: \(code)"
        case .noResponse:
            return "No response from AI"
        }
    }
}
