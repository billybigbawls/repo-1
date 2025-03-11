//
//  AI.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI
import Foundation

public struct AI: Identifiable, Codable {
    public let id: UUID
    let name: String
    let category: AICategory
    let description: String
    var avatar: String
    var backgroundColor: String
    var isLocked: Bool
    var stats: AIStats
    var securityEnabled: Bool
    
    // Squad support
    var isSquad: Bool = false
    var squadMembers: [AI]? = nil
    
    // Computed properties
    var displayName: String {
        if isSquad {
            return "\(name) Squad"
        }
        return name
    }
    
    var displayDescription: String {
        if isSquad, let members = squadMembers {
            return "A squad featuring: \(members.map { $0.name }.joined(separator: ", "))"
        }
        return description
    }
    
    enum AICategory: String, Codable, CaseIterable {
        case friend
        case professional
        case creative
        case utility
        case specialist
        
        var displayName: String {
            switch self {
            case .friend:
                return "Friend"
            case .professional:
                return "Professional"
            case .creative:
                return "Creative"
            case .utility:
                return "Utility"
            case .specialist:
                return "Specialist"
            }
        }
    }
    
    struct AIStats: Codable {
        var messagesCount: Int
        var responseTime: Double
        var userRating: Double
        var lastInteraction: Date
        
        // Squad-specific stats
        var combinedEffectiveness: Double?
        var interactionQuality: Double?
        
        static func defaultStats() -> AIStats {
            return AIStats(
                messagesCount: 0,
                responseTime: 0.0,
                userRating: 5.0,
                lastInteraction: Date()
            )
        }
    }
    
    // Factory methods for creating AIs
    static func createIndividual(
        name: String,
        category: AICategory,
        description: String
    ) -> AI {
        AI(
            id: UUID(),
            name: name,
            category: category,
            description: description,
            avatar: "default_avatar",
            backgroundColor: "default",
            isLocked: false,
            stats: AIStats.defaultStats(),
            securityEnabled: false,
            isSquad: false,
            squadMembers: nil
        )
    }
    
    static func createSquad(
        name: String,
        members: [AI]
    ) -> AI {
        AI(
            id: UUID(),
            name: name,
            category: .specialist,
            description: "A squad of \(members.count) AIs",
            avatar: "squad_avatar",
            backgroundColor: "squad_background",
            isLocked: false,
            stats: AIStats.defaultStats(),
            securityEnabled: false,
            isSquad: true,
            squadMembers: members
        )
    }
}

// MARK: - Helper Extensions
extension AI {
    func combinePersonalities() -> String {
        guard isSquad, let members = squadMembers else {
            return description
        }
        
        let personalities = members.map { $0.description }
        return "Combined expertise of: \(personalities.joined(separator: " + "))"
    }
    
    var isAvailable: Bool {
        !isLocked && (!securityEnabled || isAuthenticated)
    }
    
    private var isAuthenticated: Bool {
        // Add authentication check logic here
        true
    }
}

// MARK: - Equatable
extension AI: Equatable {
    static public func == (lhs: AI, rhs: AI) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable
extension AI: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AI.AICategory {
    public var color: Color {
        switch self {
        case .friend:
            if #available(iOS 17.0, *) {
                return Color(.systemBlue)
            } else {
                return Color(UIColor.systemBlue)
            }
        case .professional:
            if #available(iOS 17.0, *) {
                return Color(.systemPurple)
            } else {
                return Color(UIColor.systemPurple)
            }
        case .creative:
            if #available(iOS 17.0, *) {
                return Color(.systemOrange)
            } else {
                return Color(UIColor.systemOrange)
            }
        case .utility:
            if #available(iOS 17.0, *) {
                return Color(.systemGreen)
            } else {
                return Color(UIColor.systemGreen)
            }
        case .specialist:
            if #available(iOS 17.0, *) {
                return Color(.systemRed)
            } else {
                return Color(UIColor.systemRed)
            }
        }
    }
}
