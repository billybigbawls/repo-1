//
//  User.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    let deviceId: String
    var email: String?
    var settings: UserSettings
    var preferences: UserPreferences
    var stats: UserStats
}
