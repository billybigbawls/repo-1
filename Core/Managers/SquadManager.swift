//
//  SquadManager.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import Foundation
import Combine

class SquadManager: ObservableObject {
    static let shared = SquadManager()
    
    @Published private(set) var squads: [Squad] = []
    @Published private(set) var activeSquad: Squad?
    @Published var selectedAIs: Set<AI> = []
    
    private let storageService = StorageService()
    private let aiManager = AIManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSquads()
        setupSubscriptions()
    }
    
    // MARK: - Public Methods
    
    func createSquad(name: String, ais: [AI]) throws -> Squad {
        // Validate squad requirements
        guard ais.count >= 2 && ais.count <= 3 else {
            throw SquadError.invalidAICount
        }
        
        guard !name.isEmpty else {
            throw SquadError.invalidName
        }
        
        // Create new squad
        let squad = Squad(
            id: UUID(),
            name: name,
            members: ais,
            createdAt: Date(),
            lastActive: Date(),
            avatar: generateSquadAvatar(for: ais),
            stats: Squad.SquadStats(
                totalInteractions: 0,
                averageResponseTime: 0,
                popularity: 0
            )
        )
        
        squads.append(squad)
        saveSquads()
        
        // Clear selected AIs
        selectedAIs.removeAll()
        
        return squad
    }
    
    func activateSquad(_ squad: Squad) {
        activeSquad = squad
        updateSquadStats(squad, interaction: .activated)
    }
    
    func deactivateSquad() {
        activeSquad = nil
    }
    
    func deleteSquad(_ squad: Squad) {
        squads.removeAll { $0.id == squad.id }
        if activeSquad?.id == squad.id {
            activeSquad = nil
        }
        saveSquads()
    }
    
    func updateSquadStats(_ squad: Squad, interaction: SquadInteraction) {
        guard var updatedSquad = squads.first(where: { $0.id == squad.id }) else { return }
        
        switch interaction {
        case .activated:
            updatedSquad.lastActive = Date()
            
        case .messaged:
            updatedSquad.stats.totalInteractions += 1
            
        case .responseTime(let time):
            let currentAvg = updatedSquad.stats.averageResponseTime
            let totalInteractions = Double(updatedSquad.stats.totalInteractions)
            updatedSquad.stats.averageResponseTime = ((currentAvg * totalInteractions) + time) / (totalInteractions + 1)
            
        case .popularity(let popularity):
            updatedSquad.stats.popularity = popularity
            
        }
        
        // Update squad in arrays
        if let index = squads.firstIndex(where: { $0.id == squad.id }) {
            squads[index] = updatedSquad
        }
        
        if activeSquad?.id == squad.id {
            activeSquad = updatedSquad
        }
        
        saveSquads()
    }
    
    func getPopularSquads(limit: Int = 5) -> [Squad] {
        return squads
            .sorted { $0.stats.popularity > $1.stats.popularity }
            .prefix(limit)
            .map { $0 }
    }
    
    func toggleAISelection(_ ai: AI) {
        if selectedAIs.contains(ai) {
            selectedAIs.remove(ai)
        } else if selectedAIs.count < 3 {
            selectedAIs.insert(ai)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSquads() {
        if let savedSquads: [Squad] = storageService.load([Squad].self, forKey: StorageService.StorageKey.squadsKey) {
            squads = savedSquads
        }
    }



    
    private func saveSquads() {
        storageService.save(squads, forKey: .squadsKey)
    }
    
    private func setupSubscriptions() {
        // Add any necessary publishers/subscribers
    }
    
    private func generateSquadAvatar(for ais: [AI]) -> String {
        // In a real app, this would generate or combine avatars
        // For now, return a placeholder
        return "squad_default"
    }
}

// MARK: - Supporting Types

private enum SquadError: Error {
    case invalidAICount
    case invalidName
    case aiNotAvailable
    case squadLimitReached
    
    var localizedDescription: String {
        switch self {
        case .invalidAICount:
            return "Squad must have 2-3 AIs"
        case .invalidName:
            return "Squad name cannot be empty"
        case .aiNotAvailable:
            return "One or more AIs are not available"
        case .squadLimitReached:
            return "Maximum number of squads reached"
        }
    }
}

enum SquadInteraction {
    case activated
    case messaged
    case responseTime(Double)
    case popularity(Double)

}

// MARK: - Preview Helpers

extension SquadManager {
    static var preview: SquadManager {
        let manager = SquadManager()
        // Add mock data if needed
        return manager
    }
}
