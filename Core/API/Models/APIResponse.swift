//
//  APIResponse.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 3/12/25.
//

import SwiftUI
import Foundation

// Generic success response
struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
    let error: String?
}

// Auth response models
struct AuthResponse: Decodable {
    let user: User
    let tokens: TokenInfo
}

struct TokenInfo: Decodable {
    let accessToken: String
    let refreshToken: String
}

// AI response model
struct AIGenerateResponse: Decodable {
    let content: String
    let metadata: AIMetadata
}

struct AIMetadata: Decodable {
    let tokens: Int
    let processingTime: Int
    let aiPersonality: String
    let promptTokens: Int
    let completionTokens: Int
}
