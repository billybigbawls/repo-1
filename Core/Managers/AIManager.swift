//
//  AIManager.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import Foundation
import Combine

extension StorageService.StorageKey {
    static let ai = StorageService.StorageKey(rawValue: "available_ais")
    static let additionalKey = StorageService.StorageKey(rawValue: "additionalKey")
    static let squads = StorageService.StorageKey(rawValue: "squads")
    static let squadKey = StorageService.StorageKey(rawValue: "squad_key")

}


class AIManager: ObservableObject {
    static let shared = AIManager()
    
    @Published private(set) var availableAIs: [AI] = []
    @Published private(set) var squads: [Squad] = []
    @Published private(set) var currentAI: AI? = nil //nill value added, placeholder
    
    private var cancellables = Set<AnyCancellable>()
    private let storageService = StorageService()
    
    init() {
        loadInitialData()
        setupSubscriptions()
    }
    
    // MARK: - Public Methods
    
    func selectAI(_ ai: AI) {
        currentAI = ai
        updateAIStats(ai: ai, interaction: .selected)
    }
    
    func addNewAI(_ ai: AI) {
        guard !availableAIs.contains(where: { $0.id == ai.id }) else { return }
        availableAIs.append(ai)
        saveAIs() // Save the updated list of AIs to storage
    }
    
    func updateAIStats(ai: AI, interaction: AIInteraction) {
        guard var updatedAI = availableAIs.first(where: { $0.id == ai.id }) else { return }
        
        switch interaction {
        case .selected:
            // Update last interaction time
            updatedAI.stats.lastInteraction = Date()
            
        case .messaged:
            // Increment message count
            updatedAI.stats.messagesCount += 1
            
        case .rated(let rating):
            // Update user rating
            let currentRating = updatedAI.stats.userRating
            let totalRatings = Double(updatedAI.stats.messagesCount)
            updatedAI.stats.userRating = ((currentRating * totalRatings) + rating) / (totalRatings + 1)
        }
        
        // Update AI in available AIs
        if let index = availableAIs.firstIndex(where: { $0.id == ai.id }) {
            availableAIs[index] = updatedAI
        }
        
        // Update current AI if needed
        if currentAI?.id == ai.id {
            currentAI = updatedAI
        }
        
        // Save changes
        saveAIs()
    }
    
    func filterAIs(by category: AI.AICategory? = nil, searchText: String = "") -> [AI] {
        var filtered = availableAIs
        
        // Apply category filter
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    func getTopAIs(limit: Int = 5) -> [AI] {
        return availableAIs
            .sorted { $0.stats.messagesCount > $1.stats.messagesCount }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Private Methods
    
    private func loadInitialData() {
        if let key = StorageService.StorageKey.ai,
           let savedAIs: [AI] = storageService.load([AI].self, forKey: key) {
            availableAIs = savedAIs
        } else {
            availableAIs = mockAIs
            saveAIs()
        }
    }
    
    private func setupSubscriptions() {
        // Setup any necessary publishers/subscribers
    }
    
    private func saveAIs() {
        if let key = StorageService.StorageKey.ai {
            storageService.save(availableAIs, forKey: key)
        }
    }
    
    // MARK: - Supporting Types
    
    enum AIInteraction {
        case selected
        case messaged
        case rated(Double)
    }
    
    // MARK: - Mock Data
    
    private let mockAIs: [AI] = [
        AI(
            id: UUID(),
            name: "Friend AI",
            category: .friend,
            description: "Your friendly AI companion for casual conversations",
            avatar: "friend_avatar",
            backgroundColor: "LightBlue",
            isLocked: false,
            stats: AI.AIStats(
                messagesCount: 0,
                responseTime: 1.0,
                userRating: 5.0,
                lastInteraction: Date()
            ),
            securityEnabled: false
        ),
        AI(
            id: UUID(),
            name: "Pro Assistant",
            category: .professional,
            description: "Professional AI for work-related tasks",
            avatar: "pro_avatar",
            backgroundColor: "PastelTan",
            isLocked: false,
            stats: AI.AIStats(
                messagesCount: 0,
                responseTime: 1.2,
                userRating: 4.8,
                lastInteraction: Date()
            ),
            securityEnabled: false
        ),
        AI(
            id: UUID(),
            name: "Creative Muse",
            category: .creative,
            description: "AI for creative inspiration and artistic collaboration",
            avatar: "creative_avatar",
            backgroundColor: "PastelPink",
            isLocked: false,
            stats: AI.AIStats(
                messagesCount: 0,
                responseTime: 1.5,
                userRating: 4.9,
                lastInteraction: Date()
            ),
            securityEnabled: false
        )
    ]
}
