
//
//  UserTypes.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 12/29/24.
//

import Foundation

// MARK: - Enums
enum ThemePreference: String, Codable, CaseIterable {
    case light
    case dark
    case system
}

enum ResponseLength: String, Codable, CaseIterable {
    case small
    case medium
    case large
}

enum ResponseFrequency: String, Codable, CaseIterable {
    case rarely
    case occasionally
    case frequently
}

// MARK: - Types

struct UserSettings: Codable {
    var appSecurityEnabled: Bool = false
    var notificationsEnabled: Bool = true
    var locationEnabled: Bool = false
    var theme: ThemePreference = .system
    var language: String = "en"
    var email: String?
}

struct UserPreferences: Codable {
    var defaultResponseLength: ResponseLength = .medium
    var aiResponseFrequency: ResponseFrequency = .occasionally
    var preferredBackground: String = "default"
}

struct UserStats: Codable {
    var totalMessages: Int
    var favoriteAIs: [UUID]
    var activeSquads: [UUID]
    var lastActive: Date
}
