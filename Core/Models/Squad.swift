//
//  Squad.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import Foundation

struct Squad: Identifiable, Codable {
    let id: UUID
    var name: String
    var members: [AI]
    var createdAt: Date
    var lastActive: Date
    var avatar: String
    var stats: SquadStats
    
    struct SquadStats: Codable {
        var totalInteractions: Int
        var averageResponseTime: Double
        var popularity: Double
    }
}
