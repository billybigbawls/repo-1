//
//  SecuritySettingsView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI
import LocalAuthentication

struct SecuritySettingsView: View {
    @StateObject private var viewModel = SecuritySettingsViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // App Lock Section
                SettingsCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("App Security")
                            .font(.headline)
                        
                        ToggleOption(
                            title: "\(viewModel.biometricType == .faceID ? "Face ID" : "Touch ID") Lock",
                            icon: viewModel.biometricType == .faceID ? "faceid" : "touchid",
                            isOn: $viewModel.isAppLockEnabled
                        )
                        
                        if viewModel.isAppLockEnabled {
                            ToggleOption(
                                title: "Require on Launch",
                                icon: "lock.shield",
                                isOn: $viewModel.requireOnLaunch
                            )
                        }
                    }
                }
                
                // Individual AI Security
                SettingsCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("AI Security")
                            .font(.headline)
                        
                        ForEach(viewModel.availableAIs) { ai in
                            ToggleOption(
                                title: ai.name,
                                icon: "lock",
                                isOn: viewModel.bindingForAI(ai.id)
                            )
                        }
                    }
                }
                
                // Privacy Options
                SettingsCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Privacy")
                            .font(.headline)
                        
                        ToggleOption(
                            title: "End-to-End Encryption",
                            icon: "lock.shield.fill",
                            isOn: .constant(true) // Always enabled
                        )
                        .disabled(true)
                        
                        ToggleOption(
                            title: "Hide Message Preview",
                            icon: "eye.slash",
                            isOn: $viewModel.hideMessagePreview
                        )
                        
                        ToggleOption(
                            title: "Privacy Mode",
                            icon: "hand.raised.fill",
                            isOn: $viewModel.privacyMode
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Security & Privacy")
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.lightBlue, .pastelTan, .pastelPink]),
                startPoint: .trailing,
                endPoint: .leading
            )
            .ignoresSafeArea()
        )
    }
}

class SecuritySettingsViewModel: ObservableObject {
    @Published var isAppLockEnabled = false
    @Published var requireOnLaunch = false
    @Published var hideMessagePreview = false
    @Published var privacyMode = false
    @Published var availableAIs: [AI] = []
    @Published var aiLockSettings: [UUID: Bool] = [:]
    
    let biometricType: BiometricService.BiometricType
    private let biometricService = BiometricService()
    
    init() {
        self.biometricType = biometricService.getBiometricType()
        loadSettings()
    }
    
    func bindingForAI(_ id: UUID) -> Binding<Bool> {
        Binding(
            get: { [weak self] in
                self?.aiLockSettings[id] ?? false
            },
            set: { [weak self] newValue in
                self?.aiLockSettings[id] = newValue
                self?.saveSettings()
            }
        )
    }
    
    private func loadSettings() {
        // Load settings from UserDefaults or other storage
    }
    
    private func saveSettings() {
        // Save settings to UserDefaults or other storage
    }
}

#Preview {
    NavigationView {
        SecuritySettingsView()
    }
}
