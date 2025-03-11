//
//  ChatResponse.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 11/12/24.
//

import Foundation

struct ChatResponse: Codable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
    let usage: Usage
    
    struct Choice: Codable {
        let index: Int
        let message: Message
        let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
    
    struct Usage: Codable {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}

// Helper extensions for response handling
extension ChatResponse {
    var firstResponse: String? {
        choices.first?.message.content
    }
    
    var tokenCount: Int {
        usage.totalTokens
    }
    
    var isComplete: Bool {
        choices.first?.finishReason == "stop"
    }
}

// Error response handling
struct ChatErrorResponse: Codable {
    let error: ErrorDetails
    
    struct ErrorDetails: Codable {
        let message: String
        let type: String
        let code: String?
    }
}

// Response metadata for caching and analytics
struct ResponseMetadata {
    let timestamp: Date
    let tokenCount: Int
    let latency: TimeInterval
    let model: String
    
    init(response: ChatResponse, latency: TimeInterval) {
        self.timestamp = Date()
        self.tokenCount = response.usage.totalTokens
        self.latency = latency
        self.model = response.model
    }
}

// Usage tracking
class UsageTracker {
    static let shared = UsageTracker()
    
    private var dailyTokenCount = 0
    private var lastReset = Date()
    
    private init() {
        resetDailyCount()
    }
    
    func trackUsage(_ response: ChatResponse) {
        dailyTokenCount += response.tokenCount
    }
    
    func getDailyTokenCount() -> Int {
        return dailyTokenCount
    }
    
    private func resetDailyCount() {
        Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { [weak self] _ in
            self?.dailyTokenCount = 0
            self?.lastReset = Date()
        }
    }
}
