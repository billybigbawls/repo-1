//
//  SettingsViewModel.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/28/24.
//

import SwiftUI
import Combine
import UIKit
import UserNotifications

class SettingsViewModel: ObservableObject {
    // MARK: - Constants
    let biometricType: BiometricService.BiometricType
    
    // MARK: - Published Properties
    @Published var isAppLockEnabled = false
    @Published var colorScheme: ColorScheme = .light
    @Published var theme: Theme = .classic
    @Published var notificationSettings = NotificationSettings()
    @Published var isLocationEnabled = false
    @Published var locationUpdateFrequency: LocationUpdateFrequency = .medium
    @Published var defaultResponseLength: ResponseLength = .medium
    @Published var messageFrequency: MessageFrequency = .occasionally
    @Published var linguistics = LinguisticSettings()
    @Published var deviceID: String = ""
    @Published var email: String?
    @Published var isLoggedIn = false
    @Published var individualAILocks: [UUID: Bool] = [:]
    @Published var errorMessage: String?
    
    // MARK: - Services
    private let userManager = UserManager.shared
    private let aiManager = AIManager.shared
    private let biometricService = BiometricService()
    private let storageService = StorageService()
    private let notificationService = NotificationService()
    private let locationService = LocationService()
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        self.biometricType = BiometricService().getBiometricType() // Initialize biometricType
        loadSettings()
        setupSubscriptions()
    }
    
    // MARK: - Public Methods
    
    func toggleAppLock() async {
        do {
            try await userManager.toggleBiometricAuth()
            isAppLockEnabled = userManager.settings.appSecurityEnabled
            HapticManager.success()
        } catch {
            showError(error.localizedDescription)
        }
    }
    
    func toggleIndividualAILock(for aiID: UUID) {
        guard isAppLockEnabled else {
            showError("Please enable app lock first")
            return
        }
        
        individualAILocks[aiID]?.toggle()
        saveSettings()
        HapticManager.selection()
    }
    
    func updateColorScheme(_ newScheme: ColorScheme) {
        colorScheme = newScheme
        saveSettings()
    }
    
    func updateTheme(_ newTheme: Theme) {
        theme = newTheme
        saveSettings()
    }
    
    func updateNotificationSettings(_ settings: NotificationSettings) {
        notificationSettings = settings
        
        if settings.pushEnabled {
            requestNotificationPermission()
        }
        
        saveSettings()
    }
    
    func toggleLocationServices() {
        isLocationEnabled.toggle()
        
        if isLocationEnabled {
            locationService.requestLocationPermission()
        }
        
        saveSettings()
    }
    
    func updateResponseLength(_ length: ResponseLength) {
        defaultResponseLength = length
        saveSettings()
    }
    
    func updateMessageFrequency(_ frequency: MessageFrequency) {
        messageFrequency = frequency
        saveSettings()
    }
    
    func updateLinguistics(_ settings: LinguisticSettings) {
        linguistics = settings
        saveSettings()
    }
    
    func signOut() {
        userManager.logout()
        isLoggedIn = false
        email = nil
        HapticManager.success()
    }
    
    // MARK: - Private Methods
    
    private func loadSettings() {
        // Use the keys defined in your StorageProvider.
        if let settings: UserSettings = storageService.load(UserSettings.self, forKey: .settings) {
            isAppLockEnabled = settings.appSecurityEnabled
            isLocationEnabled = settings.locationEnabled
            email = settings.email
            isLoggedIn = settings.email != nil
        }
        
        deviceID = UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
        
        // Load individual AI locks using the .aiLocks key.
        if let locks: [UUID: Bool] = storageService.load([UUID: Bool].self, forKey: .aiLocks) {
            individualAILocks = locks
        }
    }
    
    private func setupSubscriptions() {
        userManager.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.email = user?.email
                self?.isLoggedIn = user != nil
            }
            .store(in: &cancellables)
        
        aiManager.$availableAIs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ais in
                self?.updateAILocks(for: ais)
            }
            .store(in: &cancellables)
    }
    
    private func saveSettings() {
        let settings = UserSettings(
            appSecurityEnabled: isAppLockEnabled,
            notificationsEnabled: notificationSettings.pushEnabled,
            locationEnabled: isLocationEnabled,
            theme: ThemePreference(rawValue: theme.rawValue) ?? .system,
            language: linguistics.language,
            email: email
        )
        
        storageService.save(settings, forKey: .settings)
        storageService.save(individualAILocks, forKey: .aiLocks)
    }
    
    private func requestNotificationPermission() {
        notificationService.requestPermission()
    }
    
    private func updateAILocks(for ais: [AI]) {
        // Add new AIs to locks if not present.
        for ai in ais where individualAILocks[ai.id] == nil {
            individualAILocks[ai.id] = false
        }
        
        // Remove locks for AIs that no longer exist.
        individualAILocks = individualAILocks.filter { key, _ in
            ais.contains { $0.id == key }
        }
        
        saveSettings()
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        HapticManager.error()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.errorMessage = nil
            }
        }
    }
}

// MARK: - Supporting Types

enum MessageFrequency: String, CaseIterable {
    case rarely
    case occasionally
    case frequently
    
    var displayName: String {
        switch self {
        case .rarely: return "Rarely"
        case .occasionally: return "Occasionally"
        case .frequently: return "Frequently"
        }
    }
}

enum Theme: String, CaseIterable {
    case classic
    case dark
    case light
    case nature
    case ocean
}

enum LocationUpdateFrequency: String, CaseIterable {
    case low
    case medium
    case high
}

struct NotificationSettings: Codable {
    var pushEnabled: Bool = true
    var aiMessages: Bool = true
    var locationUpdates: Bool = true
    var squadActivities: Bool = true
}

struct LinguisticSettings: Codable {
    var language: String = "en"
    var region: String = "US"
    var formalityLevel: FormalityLevel = .neutral
    var customVocabulary: [String] = []
    
    enum FormalityLevel: String, CaseIterable, Codable {
        case casual
        case neutral
        case formal
    }
}

// MARK: - Preview Helper
extension SettingsViewModel {
    static var preview: SettingsViewModel {
        let viewModel = SettingsViewModel()
        return viewModel
    }
}
