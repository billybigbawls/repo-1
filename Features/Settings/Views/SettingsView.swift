//
//  SettingsView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//


import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [.lightBlue, .pastelTan, .pastelPink]),
                    startPoint: .trailing,
                    endPoint: .leading
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Security Section
                        SecuritySettingsSection(
                            isAppLockEnabled: $viewModel.isAppLockEnabled,
                            biometricType: viewModel.biometricType,
                            individualAILocks: $viewModel.individualAILocks
                        )
                        
                        // Appearance Section
                        AppearanceSection(
                            colorScheme: $viewModel.colorScheme,
                            theme: $viewModel.theme
                        )
                        
                        // Notifications Section
                        NotificationSection(
                            settings: $viewModel.notificationSettings
                        )
                        
                        // Location Section
                        LocationSection(
                            isEnabled: $viewModel.isLocationEnabled,
                            frequency: $viewModel.locationUpdateFrequency
                        )
                        
                        // API Section
                        APISettingsSection()
                        
                        // Account Section
                        AccountSection(
                            deviceID: viewModel.deviceID,
                            email: $viewModel.email,
                            isLoggedIn: $viewModel.isLoggedIn
                        )
                        
                        // AI Customization Section
                        AICustomizationSection(
                            responseLength: $viewModel.defaultResponseLength,
                            messageFrequency: $viewModel.messageFrequency,
                            linguistics: $viewModel.linguistics
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// Section Views
struct SecuritySettingsSection: View {
    @Binding var isAppLockEnabled: Bool
    let biometricType: BiometricService.BiometricType
    @Binding var individualAILocks: [UUID: Bool]
    
    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Security")
                    .font(.headline)
                
                ToggleOption(
                    title: "\(biometricType == .faceID ? "Face ID" : "Touch ID") Lock",
                    icon: biometricType == .faceID ? "faceid" : "touchid",
                    isOn: $isAppLockEnabled
                )
                
                if isAppLockEnabled {
                    Divider()
                    
                    Text("Individual AI Security")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    ForEach(Array(individualAILocks.keys), id: \.self) { aiID in
                        ToggleOption(
                            title: "Lock AI Name",
                            icon: "lock",
                            isOn: binding(for: aiID)
                        )
                        .padding(.leading)
                    }
                }
            }
        }
    }
    
    private func binding(for aiID: UUID) -> Binding<Bool> {
        Binding(
            get: { individualAILocks[aiID] ?? false },
            set: { individualAILocks[aiID] = $0 }
        )
    }
}

struct AppearanceSection: View {
    @Binding var colorScheme: ColorScheme
    @Binding var theme: Theme
    
    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Appearance")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Theme")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Color Scheme", selection: $colorScheme) {
                        Text("Light").tag(ColorScheme.light)
                        Text("Dark").tag(ColorScheme.dark)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Theme.allCases, id: \.self) { themeOption in
                            ThemePreviewButton(
                                theme: themeOption,
                                isSelected: theme == themeOption,
                                action: { theme = themeOption }
                            )
                        }
                    }
                }
            }
        }
    }
}

struct NotificationSection: View {
    @Binding var settings: NotificationSettings
    
    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Notifications")
                    .font(.headline)
                
                ToggleOption(
                    title: "Push Notifications",
                    icon: "bell.fill",
                    isOn: .constant(settings.pushEnabled)
                )
                
                if settings.pushEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        ToggleOption(
                            title: "AI Messages",
                            icon: "message.fill",
                            isOn: .constant(settings.aiMessages)
                        )
                        
                        ToggleOption(
                            title: "Location Updates",
                            icon: "location.fill",
                            isOn: .constant(settings.locationUpdates)
                        )
                        
                        ToggleOption(
                            title: "Squad Activities",
                            icon: "person.3.fill",
                            isOn: .constant(settings.squadActivities)
                        )
                    }
                    .padding(.leading)
                }
            }
        }
    }
}

struct LocationSection: View {
    @Binding var isEnabled: Bool
    @Binding var frequency: LocationUpdateFrequency
    
    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Location Services")
                    .font(.headline)
                
                ToggleOption(
                    title: "Enable Location Services",
                    icon: "location.fill",
                    isOn: $isEnabled
                )
                
                if isEnabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Update Frequency")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("", selection: $frequency) {
                            Text("Low").tag(LocationUpdateFrequency.low)
                            Text("Medium").tag(LocationUpdateFrequency.medium)
                            Text("High").tag(LocationUpdateFrequency.high)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
            }
        }
    }
}

struct AccountSection: View {
    let deviceID: String
    @Binding var email: String?
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Account")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Device ID")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(deviceID)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if isLoggedIn {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(email ?? "")
                            .font(.caption)
                    }
                    
                    Button("Log Out") {
                        isLoggedIn = false
                        email = nil
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

struct AICustomizationSection: View {
    @Binding var responseLength: ResponseLength
    @Binding var messageFrequency: MessageFrequency
    @Binding var linguistics: LinguisticSettings
    
    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("AI Customization")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Default Response Length")
                        .font(.subheadline)
                    
                    Picker("", selection: $responseLength) {
                        Text("Short").tag(ResponseLength.small)
                        Text("Medium").tag(ResponseLength.medium)
                        Text("Long").tag(ResponseLength.large)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message Frequency")
                        .font(.subheadline)
                    
                    Picker("", selection: $messageFrequency) {
                        ForEach(MessageFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue.capitalized).tag(frequency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
        }
    }
}

struct SettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.white).opacity(0.1))
                    .glassMorphic()
            )
            .padding(.horizontal)
    }
}

struct APISettingsSection: View {
    @State private var apiKey: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        SettingsCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("API Settings")
                    .font(.headline)
                
                SecureField("Enter OpenAI API Key", text: $apiKey)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Save API Key") {
                    if SecureKeyManager.shared.updateAPIKey(apiKey) {
                        alertMessage = "API Key saved successfully"
                        apiKey = ""
                    } else {
                        alertMessage = "Invalid API Key format"
                    }
                    showAlert = true
                }
                .buttonStyle(.borderedProminent)
                
                if SecureKeyManager.shared.isAPIKeyStored() {
                    Text("API Key is set")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
        }
        .alert("API Key Status", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
}

#Preview {
    SettingsView()
}
