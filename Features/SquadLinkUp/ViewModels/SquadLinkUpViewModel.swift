//
//  SquadLinkUpViewModel.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/28/24.
//

import SwiftUI
import Foundation
import Combine
import UserNotifications

class SquadLinkUpViewModel: ObservableObject {
    // Published properties
    @Published var selectedAIs: Set<AI> = []
    @Published var availableAIs: [AI] = []
    @Published var searchText = ""
    @Published var squadName = ""
    @Published var isNaming = false
    @Published var showSuccessAnimation = false
    @Published var errorMessage: String?
    @Published var compatibilityScores: [UUID: Double] = [:]
    
    // Filtered AIs based on search
    @Published private(set) var filteredAIs: [AI] = []
    
    // Services & Managers
    private let aiManager = AIManager.shared
    private let squadManager = SquadManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
        loadInitialData()
    }
    
    // MARK: - Public Methods
    
    func selectAI(_ ai: AI) {
        guard selectedAIs.count < 3 || selectedAIs.contains(ai) else {
            showError("Maximum 3 AIs allowed per squad")
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
        
        calculateCompatibility()
    }
    
    func removeAI(_ ai: AI) {
      _ =  withAnimation(.spring()) {
            selectedAIs.remove(ai)
        }
        calculateCompatibility()
        HapticManager.impact(style: .light)
    }
    
    func createSquad() {
        guard validateSquadCreation() else { return }
        
        do {
            let squad = try squadManager.createSquad(
                name: squadName,
                ais: Array(selectedAIs)
            )
            
            // Show success animation
            withAnimation(.spring()) {
                showSuccessAnimation = true
            }
            
            // Success feedback
            HapticManager.success()
            
            // Reset after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.resetState()
            }
            
            // Notify success
            NotificationService.shared.scheduleSquadCreationNotification(squad: squad)
            
        } catch {
            showError(error.localizedDescription)
        }
    }
    
    func filterAIs() {
        var filtered = availableAIs
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        withAnimation {
            filteredAIs = filtered
        }
    }
    
    // MARK: - Private Methods
    
    private func setupSubscriptions() {
        // Listen for search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.filterAIs()
            }
            .store(in: &cancellables)
        
        // Listen for AI updates
        aiManager.$availableAIs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ais in
                self?.availableAIs = ais
                self?.filterAIs()
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        availableAIs = aiManager.availableAIs
        filteredAIs = availableAIs
    }
    
    private func calculateCompatibility() {
        guard selectedAIs.count >= 2 else {
            compatibilityScores.removeAll()
            return
        }
        
        // Calculate compatibility between all selected AIs
        for ai in selectedAIs {
            for otherAI in selectedAIs where ai.id != otherAI.id {
                let score = calculateCompatibilityScore(between: ai, and: otherAI)
                let key = UUID(uuidString: "\(ai.id)-\(otherAI.id)") ?? UUID()
                compatibilityScores[key] = score
            }
        }
    }
    
    private func calculateCompatibilityScore(between ai1: AI, and ai2: AI) -> Double {
        // Mock compatibility calculation
        // In a real app, this would use more sophisticated criteria
        let categoryMatch = ai1.category == ai2.category ? 0.3 : 0.0
        let ratingMatch = 1.0 - abs(ai1.stats.userRating - ai2.stats.userRating) / 5.0
        let popularityMatch = Double.random(in: 0.0...0.3) // Random factor for variety
        
        return categoryMatch + ratingMatch + popularityMatch
    }
    
    private func validateSquadCreation() -> Bool {
        if squadName.isEmpty {
            showError("Please enter a squad name")
            return false
        }
        
        if selectedAIs.count < 2 {
            showError("Please select at least 2 AIs")
            return false
        }
        
        if selectedAIs.count > 3 {
            showError("Maximum 3 AIs allowed")
            return false
        }
        
        return true
    }
    
    private func resetState() {
        withAnimation {
            showSuccessAnimation = false
            isNaming = false
            squadName = ""
            selectedAIs.removeAll()
            compatibilityScores.removeAll()
        }
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
extension SquadLinkUpViewModel {
    static var preview: SquadLinkUpViewModel {
        let viewModel = SquadLinkUpViewModel()
        // Add mock data for preview if needed
        return viewModel
    }
}

// MARK: - Notification Extension
extension NotificationService {
    func scheduleSquadCreationNotification(squad: Squad) {
        let content = UNMutableNotificationContent()
        content.title = "New Squad Created!"
        content.body = "Your squad '\(squad.name)' is ready for action!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}
