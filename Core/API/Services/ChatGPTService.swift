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
        
        guard let apiKey = secureKeyManager.getAPIKey() else {
            completion(.failure(APIError.noAPIKey))
            return
        }
        
        // Check rate limiting
        guard canMakeRequest() else {
            completion(.failure(APIError.rateLimitExceeded))
            return
        }
        
        // Construct messages array
        var messages: [[String: Any]] = [
            ["role": "system", "content": aiPersonality],
            ["role": "user", "content": message]
        ]
        
        // Add recent message history
        let recentMessages = truncateHistory(messageHistory)
        messages.insert(contentsOf: recentMessages.map {
            ["role": $0.sender == .user ? "user" : "assistant",
             "content": $0.content]
        }, at: 1)
        
        // Create request
        let requestBody: [String: Any] = [
            "model": APIConfig.model,
            "messages": messages,
            "max_tokens": APIConfig.maxTokens,
            "temperature": APIConfig.temperature,
            "stream": false
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(APIError.invalidRequest))
            return
        }
        
        var request = URLRequest(url: Endpoint.chatCompletions.url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = APIConfig.headers(with: apiKey)
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
                case 429:
                    throw APIError.rateLimitExceeded
                case 401:
                    throw APIError.unauthorized
                default:
                    throw APIError.serverError(httpResponse.statusCode)
                }
            }
            .decode(type: ChatResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    }
                },
                receiveValue: { response in
                    if let message = response.choices.first?.message.content {
                        self.cacheResponse(message, for: aiPersonality)
                        completion(.success(message))
                    } else {
                        completion(.failure(APIError.noResponse))
                    }
                }
            )
            .store(in: &cancellables)
        
        incrementRequestCount()
    }
    
    // MARK: - Private Methods
    
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

// MARK: - Error Types

enum APIError: Error {
    case noAPIKey
    case invalidRequest
    case invalidResponse
    case rateLimitExceeded
    case unauthorized
    case serverError(Int)
    case noResponse
    
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
            return "Unauthorized. Please check your API key."
        case .serverError(let code):
            return "Server error: \(code)"
        case .noResponse:
            return "No response from AI"
        }
    }
}
