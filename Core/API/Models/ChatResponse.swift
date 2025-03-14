//
//  ChatResponse.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 11/12/24.
//

import Foundation

// MARK: - Chat Response Models

struct ChatResponse: Codable {
    let content: String
    let metadata: ResponseMetadata
    
    enum CodingKeys: String, CodingKey {
        case content
        case metadata
    }
}

struct ResponseMetadata: Codable {
    let tokens: Int
    let processingTime: Double
    let aiPersonality: String
    let promptTokens: Int?
    let completionTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case tokens
        case processingTime = "processing_time"
        case aiPersonality = "ai_personality"
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
    }
}

// MARK: - Chat Request Models

struct ChatRequest: Codable {
    let message: String
    let aiId: String?
    let settings: RequestSettings?
    
    enum CodingKeys: String, CodingKey {
        case message
        case aiId = "ai_id"
        case settings
    }
}

struct RequestSettings: Codable {
    let maxTokens: Int?
    let temperature: Double?
    let language: String?
    
    enum CodingKeys: String, CodingKey {
        case maxTokens = "max_tokens"
        case temperature
        case language
    }
}

// MARK: - AI Personality Models

struct AIPersonality: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let personalityType: String
    let temperament: String
    let speakingStyle: String
    let responseLength: String
    let isActive: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case personalityType = "personality_type"
        case temperament
        case speakingStyle = "speaking_style"
        case responseLength = "response_length"
        case isActive = "is_active"
    }
}

// MARK: - Message Models

struct MessageResponse: Codable {
    let id: String
    let content: String
    let createdAt: Date
    let isAI: Bool
    let metadata: MessageMetadata?
    let userId: String?
    let aiId: String?
    let squadId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case createdAt = "created_at"
        case isAI = "is_ai"
        case metadata
        case userId = "user_id"
        case aiId = "ai_id"
        case squadId = "squad_id"
    }
}

struct MessageMetadata: Codable {
    let tokens: Int?
    let responseType: String?
    let processingTime: Double?
    let aiPersonality: String?
    
    enum CodingKeys: String, CodingKey {
        case tokens
        case responseType = "response_type"
        case processingTime = "processing_time"
        case aiPersonality = "ai_personality"
    }
}

struct MessagesResponse: Codable {
    let messages: [MessageResponse]
    let totalCount: Int
    let hasMore: Bool
    
    enum CodingKeys: String, CodingKey {
        case messages
        case totalCount = "total_count"
        case hasMore = "has_more"
    }
}

// MARK: - Error Models

struct ErrorResponse: Codable {
    let error: String
    let message: String
    let statusCode: Int?
    
    enum CodingKeys: String, CodingKey {
        case error
        case message
        case statusCode = "status_code"
    }
}
