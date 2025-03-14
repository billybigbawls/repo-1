//
//  SquadAPIService.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 3/13/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError
    case networkError
    case serverError(String)
    case authenticationError
    case validationError(String)
    case notFoundError
}

class SquadAPIService {
    static let shared = SquadAPIService()
    
    private let session: URLSession
    private let jsonDecoder: JSONDecoder
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConfig.requestTimeout
        self.session = URLSession(configuration: config)
        
        self.jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Auth Methods
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        return try await request(
            endpoint: APIConfig.loginEndpoint,
            method: "POST",
            body: body
        )
    }
    
    func register(email: String, password: String, name: String?) async throws -> AuthResponse {
        var body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        if let name = name {
            body["name"] = name
        }
        
        return try await request(
            endpoint: APIConfig.registerEndpoint,
            method: "POST",
            body: body
        )
    }
    
    func refreshToken(refreshToken: String) async throws -> TokenInfo {
        let body: [String: Any] = [
            "refreshToken": refreshToken
        ]
        
        return try await request(
            endpoint: APIConfig.refreshTokenEndpoint,
            method: "POST",
            body: body
        )
    }
    
    // MARK: - AI Methods
    
    func generateAIResponse(prompt: String, aiId: String? = nil, squadId: String? = nil) async throws -> AIGenerateResponse {
        var body: [String: Any] = [
            "message": prompt
        ]
        
        if let aiId = aiId {
            body["aiId"] = aiId
        }
        
        if let squadId = squadId {
            body["squadId"] = squadId
        }
        
        return try await authenticatedRequest(
            endpoint: APIConfig.aiGenerateEndpoint,
            method: "POST",
            body: body
        )
    }
    
    func getAIPersonalities() async throws -> [AI] {
        return try await authenticatedRequest(
            endpoint: APIConfig.aiPersonalitiesEndpoint,
            method: "GET"
        )
    }
    
    // MARK: - Squad Methods
    
    func getSquads() async throws -> [Squad] {
        return try await authenticatedRequest(
            endpoint: APIConfig.squadsEndpoint,
            method: "GET"
        )
    }
    
    func createSquad(name: String, description: String? = nil, maxMembers: Int? = nil) async throws -> Squad {
        var body: [String: Any] = [
            "name": name
        ]
        
        if let description = description {
            body["description"] = description
        }
        
        if let maxMembers = maxMembers {
            body["maxMembers"] = maxMembers
        }
        
        return try await authenticatedRequest(
            endpoint: APIConfig.squadsEndpoint,
            method: "POST",
            body: body
        )
    }
    
    // MARK: - Generic Request Methods
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String,
        headers: [String: String]? = nil,
        body: [String: Any]? = nil
    ) async throws -> T {
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Add headers
        let requestHeaders = headers ?? APIConfig.defaultHeaders()
        for (key, value) in requestHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add body for POST/PUT requests
        if let body = body, (method == "POST" || method == "PUT") {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw APIError.invalidURL
            }
        }
        
        // Make request
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            // Handle response based on status code
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    return try jsonDecoder.decode(T.self, from: data)
                } catch {
                    print("Decoding error: \(error)")
                    throw APIError.decodingError
                }
            case 400:
                throw APIError.validationError(parseErrorMessage(from: data))
            case 401, 403:
                throw APIError.authenticationError
            case 404:
                throw APIError.notFoundError
            case 500...599:
                throw APIError.serverError(parseErrorMessage(from: data))
            default:
                throw APIError.networkError
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError
        }
    }
    
    private func authenticatedRequest<T: Decodable>(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil
    ) async throws -> T {
        guard let token = SecureKeyManager.shared.getAccessToken() else {
            throw APIError.authenticationError
        }
        
        let headers = APIConfig.authHeaders(token: token)
        
        do {
            return try await request(
                endpoint: endpoint,
                method: method,
                headers: headers,
                body: body
            )
        } catch APIError.authenticationError {
            // Try to refresh token
            if let refreshToken = SecureKeyManager.shared.getRefreshToken() {
                do {
                    let tokenInfo: TokenInfo = try await request(
                        endpoint: APIConfig.refreshTokenEndpoint,
                        method: "POST",
                        body: ["refreshToken": refreshToken]
                    )
                    
                    // Save new token
                    _ = SecureKeyManager.shared.storeAccessToken(tokenInfo.accessToken)
                    
                    // Retry with new token
                    let newHeaders = APIConfig.authHeaders(token: tokenInfo.accessToken)
                    return try await request(
                        endpoint: endpoint,
                        method: method,
                        headers: newHeaders,
                        body: body
                    )
                } catch {
                    throw APIError.authenticationError
                }
            } else {
                throw APIError.authenticationError
            }
        }
    }
    
    private func parseErrorMessage(from data: Data) -> String {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMessage = json["error"] as? String {
                return errorMessage
            }
        } catch {
            // Ignore parsing error
        }
        return "Unknown error occurred"
    }
}
