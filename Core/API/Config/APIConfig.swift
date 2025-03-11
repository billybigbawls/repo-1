//
//  APIConfig.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 11/12/24.
//

import Foundation

struct APIConfig {
    static let baseURL = "https://api.openai.com/v1/chat/completions"
    static let model = "gpt-3.5-turbo"
    
    // Default parameters
    static let maxTokens = 150
    static let temperature = 0.7
    static let messageHistoryLimit = 10
    
    // API Limits
    static let tokenLimit = 4096
    static let requestsPerMinute = 3
    
    // Don't store actual key here - will be handled by SecureKeyManager
    private static let apiKey: String = ""
    
    // Headers
    static func headers(with apiKey: String) -> [String: String] {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
}

// Rate limiting
struct APILimits {
    static let maxRequestsPerMinute = 3
    static let cooldownPeriod: TimeInterval = 60
    static let retryAttempts = 3
    static let retryDelay: TimeInterval = 2
}

// Endpoint configurations
enum Endpoint {
    case chatCompletions
    
    var path: String {
        switch self {
        case .chatCompletions:
            return "/v1/chat/completions"
        }
    }
    
    var url: URL {
        return URL(string: APIConfig.baseURL + path)!
    }
}
