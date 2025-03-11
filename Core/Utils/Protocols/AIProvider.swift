//
//  AIProvider.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/28/24.
//

import Foundation

enum AIInteraction {
    case messageReceived
    case messageSent
    case userInteracted
    case offline
    // Add other interaction types as needed
}

protocol AIProvider {
    // Basic AI management
    func fetchAvailableAIs() async throws -> [AI]
    func getAI(byID id: UUID) -> AI?
    func updateAI(_ ai: AI)
    
    // Stats and interactions
    func updateStats(forAI id: UUID, interaction: AIInteraction)
    func getTopAIs(limit: Int) async throws -> [AI]
    
    // Filtering and search
    func filterAIs(byCategory category: AI.AICategory?) async throws -> [AI]
    func searchAIs(matching query: String) async throws -> [AI]
    
    // Squad related
    func checkCompatibility(between ai1: UUID, and ai2: UUID) -> Double
    func createSquad(name: String, aiIDs: [UUID]) throws -> Squad
    
    // Settings and preferences
    func toggleSecurity(forAI id: UUID)
    func setResponseLength(forAI id: UUID, length: ResponseLength)
    func setMessageFrequency(forAI id: UUID, frequency: MessageFrequency)
}

// Default implementations for common operations
extension AIProvider {
    func getTopAIs(limit: Int = 5) async throws -> [AI] {
        // Default implementation to get top AIs based on message count
        let allAIs = try await fetchAvailableAIs()
        return allAIs
            .sorted { $0.stats.messagesCount > $1.stats.messagesCount }
            .prefix(limit)
            .map { $0 }
    }
    
    func filterAIs(byCategory category: AI.AICategory?) async throws -> [AI] {
        let allAIs = try await fetchAvailableAIs()
        guard let category = category else { return allAIs }
        return allAIs.filter { $0.category == category }
    }
    
    func searchAIs(matching query: String) async throws -> [AI] {
        let allAIs = try await fetchAvailableAIs()
        guard !query.isEmpty else { return allAIs }
        
        return allAIs.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.description.localizedCaseInsensitiveContains(query)
        }
    }
    
    func checkCompatibility(between ai1: UUID, and ai2: UUID) -> Double {
        guard let firstAI = getAI(byID: ai1),
              let secondAI = getAI(byID: ai2) else {
            return 0.0
        }
        
        // Basic compatibility scoring
        var score = 0.0
        
        // Same category bonus
        if firstAI.category == secondAI.category {
            score += 0.3
        }
        
        // Rating similarity (0-1 scale)
        let ratingDiff = abs(firstAI.stats.userRating - secondAI.stats.userRating)
        score += (5.0 - ratingDiff) / 5.0 * 0.3
        
        // Activity level similarity
        let messageDiff = abs(
            Double(firstAI.stats.messagesCount) - Double(secondAI.stats.messagesCount)
        )
        let activityScore = max(0, 1 - (messageDiff / 1000)) * 0.4
        score += activityScore
        
        return min(1.0, max(0.0, score))
    }
}

// Error types for AI operations
enum AIProviderError: Error {
    case aiNotFound
    case invalidSquadSize
    case incompatibleAIs
    case unauthorized
    case storageError
}
