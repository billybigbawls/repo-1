//
//  ShopViewModel.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/28/24.
//

import SwiftUI
import Foundation
import Combine

private class ShopViewModel: ObservableObject {
    // Published properties
    @Published var categories: [AI.AICategory] = []
    @Published var selectedCategory: AI.AICategory?
    @Published var availableAIs: [AI] = []
    @Published var selectedAIs: Set<AI> = []
    @Published var topUsedAIs: [AI] = []
    @Published var shopkeeperAnimation: String = "shopkeeper_wave"
    @Published var errorMessage: String?
    
    // Services and Managers
    private let aiManager = AIManager.shared
    private let squadManager = SquadManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
        loadInitialData()
        startShopkeeperAnimations()
    }
    
    // MARK: - Public Methods
    
    func filterAIs() {
        withAnimation {
            availableAIs = aiManager.filterAIs(by: selectedCategory)
        }
    }
    
    func selectAI(_ ai: AI) {
        guard selectedAIs.count < 3 || selectedAIs.contains(ai) else {
            showError("You can only select up to 3 AIs")
            return
        }
        
        withAnimation(.spring()) {
            if selectedAIs.contains(ai) {
                selectedAIs.remove(ai)
            } else {
                selectedAIs.insert(ai)
                HapticManager.selection()
            }
        }
    }
    
    func createSquad(name: String) {
        guard selectedAIs.count >= 2 else {
            showError("Please select at least 2 AIs")
            return
        }
        
        do {
            let squad = try squadManager.createSquad(
                name: name,
                ais: Array(selectedAIs)
            )
            
            // Success feedback
            HapticManager.success()
            
            // Reset selection
            withAnimation {
                selectedAIs.removeAll()
            }
            
            // Update stats
            updateSquadStats(squad)
        } catch {
            showError(error.localizedDescription)
        }
    }
    
    func updateProgress() {
        topUsedAIs = aiManager.getTopAIs(limit: 5)
    }
    
    // MARK: - Private Methods
    
    private func setupSubscriptions() {
        // Listen for AI updates
        aiManager.$availableAIs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ais in
                self?.availableAIs = ais
                self?.updateProgress()
            }
            .store(in: &cancellables)
        
        // Listen for squad updates
        squadManager.$squads
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateProgress()
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        categories = AI.AICategory.allCases
        availableAIs = aiManager.availableAIs
        topUsedAIs = aiManager.getTopAIs(limit: 5)
    }
    
    private func startShopkeeperAnimations() {
        // Cycle through different animations
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.cycleShopkeeperAnimation()
        }
    }
    
    private func cycleShopkeeperAnimation() {
        let animations = [
            "shopkeeper_wave",
            "shopkeeper_point",
            "shopkeeper_celebrate"
        ]
        
        if let currentIndex = animations.firstIndex(of: shopkeeperAnimation) {
            let nextIndex = (currentIndex + 1) % animations.count
            withAnimation {
                shopkeeperAnimation = animations[nextIndex]
            }
        }
    }
    
    private func updateSquadStats(_ squad: Squad) {
        // Update popularity based on member AIs' stats
        let popularity = calculateSquadPopularity(squad)
        squadManager.updateSquadStats(squad, interaction: .popularity(popularity))
    }
    
    private func calculateSquadPopularity(_ squad: Squad) -> Double {
        let totalMessages = squad.members.reduce(0) { $0 + $1.stats.messagesCount }
        let avgRating = squad.members.reduce(0.0) { $0 + $1.stats.userRating } / Double(squad.members.count)
        
        return Double(totalMessages) * avgRating / 100.0
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        HapticManager.error()
        
        // Clear error after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.errorMessage = nil
            }
        }
    }
}

// MARK: - Preview Helper
extension ShopViewModel {
    static var preview: ShopViewModel {
        let viewModel = ShopViewModel()
        // Add mock data for preview if needed
        return viewModel
    }
}

// MARK: - Supporting Types
private enum SquadError: Error {
    case maxAIsReached
    case minAIsRequired
    case invalidName
    
    var localizedDescription: String {
        switch self {
        case .maxAIsReached:
            return "Maximum 3 AIs allowed per squad"
        case .minAIsRequired:
            return "Minimum 2 AIs required for a squad"
        case .invalidName:
            return "Please enter a valid squad name"
        }
    }
}
