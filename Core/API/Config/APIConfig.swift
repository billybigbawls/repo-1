//
//  APIConfig.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 11/12/24.
//

import Foundation

struct APIConfig {
    // Change baseURL to your backend
    #if DEBUG
    static let baseURL = "http://localhost:3000" // Development
    #else
    static let baseURL = "https://your-production-domain.com" // Production
    #endif
    
    // API version
    static let apiVersion = "v1"
    
    // Auth endpoints
    static let loginEndpoint = "/api/\(apiVersion)/auth/login"
    static let registerEndpoint = "/api/\(apiVersion)/auth/register"
    static let refreshTokenEndpoint = "/api/\(apiVersion)/auth/refresh-token"
    
    // User endpoints
    static let userEndpoint = "/api/\(apiVersion)/users/me"
    
    // Squad endpoints
    static let squadsEndpoint = "/api/\(apiVersion)/squads"
    
    // AI endpoints
    static let aiGenerateEndpoint = "/api/\(apiVersion)/ai/generate"
    static let aiPersonalitiesEndpoint = "/api/\(apiVersion)/ai/personalities"
    
    // Contact endpoint
    static let contactEndpoint = "/api/\(apiVersion)/contact"
    
    // Default parameters
    static let maxTokens = 150
    static let temperature = 0.7
    static let messageHistoryLimit = 10
    
    // Request timeouts
    static let requestTimeout: TimeInterval = 30
    
    // Headers
    static func defaultHeaders() -> [String: String] {
        return [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
    }
    
    static func authHeaders(token: String) -> [String: String] {
        var headers = defaultHeaders()
        headers["Authorization"] = "Bearer \(token)"
        return headers
    }
}

// Endpoint configurations
enum Endpoint {
    case login
    case register
    case refreshToken
    case user
    case squads
    case squad(id: String)
    case aiGenerate
    case aiPersonalities
    case contact
    
    var path: String {
        switch self {
        case .login:
            return APIConfig.loginEndpoint
        case .register:
            return APIConfig.registerEndpoint
        case .refreshToken:
            return APIConfig.refreshTokenEndpoint
        case .user:
            return APIConfig.userEndpoint
        case .squads:
            return APIConfig.squadsEndpoint
        case .squad(let id):
            return "\(APIConfig.squadsEndpoint)/\(id)"
        case .aiGenerate:
            return APIConfig.aiGenerateEndpoint
        case .aiPersonalities:
            return APIConfig.aiPersonalitiesEndpoint
        case .contact:
            return APIConfig.contactEndpoint
        }
    }
    
    var url: URL {
        return URL(string: APIConfig.baseURL + path)!
    }
}

// API limits (retained from original config)
struct APILimits {
    static let maxRequestsPerMinute = 3
    static let cooldownPeriod: TimeInterval = 60
    static let retryAttempts = 3
    static let retryDelay: TimeInterval = 2
}
