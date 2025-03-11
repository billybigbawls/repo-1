//
//  UserManager.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import Foundation
import Combine
import UIKit
import LocalAuthentication

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published private(set) var currentUser: User?
    @Published private(set) var settings: UserSettings = UserSettings()
    @Published var isAuthenticated = false
    
    private let storageService = StorageService()
    private let biometricService = BiometricService()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadUser()
        setupSubscriptions()
    }
    
    // MARK: - Authentication Methods
    
    func authenticateWithDevice() async throws {
        let deviceId = await UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        
        // Create new user if needed
        if currentUser == nil {
            let user = User(
                id: UUID(),
                deviceId: deviceId,
                email: nil,
                settings: settings,
                preferences: UserPreferences(),
                stats: UserStats(
                    totalMessages: 0,
                    favoriteAIs: [],
                    activeSquads: [],
                    lastActive: Date()
                )
            )
            currentUser = user
        }
        
        isAuthenticated = true
        saveUser()
    }
    
    func authenticateWithEmail(_ email: String, password: String) async throws {
        // Simulate network request
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        // In a real app, this would validate with a backend
        guard email.contains("@") && password.count >= 6 else {
            throw AuthError.invalidCredentials
        }
        
        let deviceId = await UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        
        let user = User(
            id: UUID(),
            deviceId: deviceId,
            email: email,
            settings: settings,
            preferences: UserPreferences(),
            stats: UserStats(
                totalMessages: 0,
                favoriteAIs: [],
                activeSquads: [],
                lastActive: Date()
            )
        )
        
        currentUser = user
        isAuthenticated = true
        saveUser()
    }
    
    func logout() {
        currentUser = nil
        isAuthenticated = false
        storageService.save(nil as User?, forKey: .user)
    }
    
    // MARK: - Settings Methods
    
    func updateSettings(_ newSettings: UserSettings) {
        settings = newSettings
        if var updatedUser = currentUser {
            updatedUser.settings = newSettings
            currentUser = updatedUser
            saveUser()
        }
    }
    
    func updatePreferences(_ newPreferences: UserPreferences) {
        if var updatedUser = currentUser {
            updatedUser.preferences = newPreferences
            currentUser = updatedUser
            saveUser()
        }
    }
    
    func toggleBiometricAuth() async throws {
        let canUseBiometrics = await biometricService.canUseBiometrics()
        guard canUseBiometrics else {
            throw AuthError.biometricsNotAvailable
        }
        
        settings.appSecurityEnabled.toggle()
        if var updatedUser = currentUser {
            updatedUser.settings.appSecurityEnabled = settings.appSecurityEnabled
            currentUser = updatedUser
            saveUser()
        }
    }
    
    // MARK: - Stats Methods
    
    func updateStats(interaction: UserInteraction) {
        guard var updatedUser = currentUser else { return }
        
        switch interaction {
        case .messageSent:
            updatedUser.stats.totalMessages += 1
            
        case .aiInteraction(let aiId):
            if !updatedUser.stats.favoriteAIs.contains(aiId) {
                updatedUser.stats.favoriteAIs.append(aiId)
            }
            
        case .squadInteraction(let squadId):
            if !updatedUser.stats.activeSquads.contains(squadId) {
                updatedUser.stats.activeSquads.append(squadId)
            }
        }
        
        updatedUser.stats.lastActive = Date()
        currentUser = updatedUser
        saveUser()
    }
    
    // MARK: - Private Methods
    
    private func loadUser() {
        if let savedUser: User = storageService.load(User.self, forKey: StorageService.StorageKey.user) {
            currentUser = savedUser
            settings = savedUser.settings
            isAuthenticated = true
        }
    }
    
    private func saveUser() {
        if let user = currentUser {
            storageService.save(user, forKey: .user)
        }
    }
    
    private func setupSubscriptions() {
        // Setup any necessary publishers/subscribers
    }
}

// MARK: - Supporting Types

enum AuthError: Error {
    case invalidCredentials
    case biometricsNotAvailable
    case networkError
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .biometricsNotAvailable:
            return "Biometric authentication is not available"
        case .networkError:
            return "Network error occurred"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

enum UserInteraction {
    case messageSent
    case aiInteraction(UUID)
    case squadInteraction(UUID)
}

// MARK: - Preview Helpers

extension UserManager {
    static var preview: UserManager {
        let manager = UserManager()
        // Add mock data if needed
        return manager
    }
}
