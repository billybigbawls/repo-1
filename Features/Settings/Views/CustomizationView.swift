//
//  CustomizationView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI


struct CustomizationView: View {
    @StateObject private var viewModel = CustomizationViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Theme Selection
                SettingsCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Theme")
                            .font(.headline)
                        
                        Picker("Color Scheme", selection: $viewModel.colorScheme) {
                            Text("Light").tag(ColorScheme.light)
                            Text("Dark").tag(ColorScheme.dark)
                            Text("System").tag(ColorScheme?.none)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.availableThemes, id: \.self) { theme in
                                    ThemePreviewButton(
                                        theme: theme,
                                        isSelected: viewModel.selectedTheme == theme,
                                        action: { viewModel.selectedTheme = theme }
                                    )
                                }
                            }
                        }
                    }
                }
                
                // AI Response Settings
                SettingsCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("AI Responses")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Default Response Length")
                                .font(.subheadline)
                            
                            Picker("", selection: $viewModel.defaultResponseLength) {
                                Text("Short").tag(ResponseLength.small)
                                Text("Medium").tag(ResponseLength.medium)
                                Text("Long").tag(ResponseLength.large)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Message Frequency")
                                .font(.subheadline)
                            
                            Picker("", selection: $viewModel.messageFrequency) {
                                ForEach(MessageFrequency.allCases, id: \.self) { frequency in
                                    Text(frequency.displayName).tag(frequency)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
                
                // Chat Background
                SettingsCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Chat Background")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(viewModel.backgroundOptions, id: \.id) { background in
                                    BackgroundPreviewButton(
                                        background: background,
                                        isSelected: viewModel.selectedBackground == background,
                                        action: { viewModel.selectedBackground = background }
                                    )
                                }
                            }
                        }
                    }
                }
                
                // Language Settings
                SettingsCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Language & Region")
                            .font(.headline)
                        
                        Picker("Language", selection: $viewModel.selectedLanguage) {
                            ForEach(viewModel.availableLanguages, id: \.code) { language in
                                Text(language.name).tag(language)
                            }
                        }
                        
                        Picker("Region", selection: $viewModel.selectedRegion) {
                            ForEach(viewModel.availableRegions, id: \.code) { region in
                                Text(region.name).tag(region)
                            }
                        }
                    }
                }
                
            }
            .padding()
        }
        .navigationTitle("Customization")
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

class CustomizationViewModel: ObservableObject {
    @Published var colorScheme: ColorScheme?
    @Published var selectedTheme: Theme = .classic
    @Published var defaultResponseLength: ResponseLength = .medium
    @Published var messageFrequency: MessageFrequency = .occasionally
    @Published var selectedLanguage: Language = Language(code: "en", name: "English")
    @Published var selectedRegion: Region = Region(code: "US", name: "United States")
    @Published var selectedBackground: BackgroundOption = .default
    
    let availableThemes: [Theme] = Theme.allCases
    let availableLanguages: [Language] = [
        Language(code: "en", name: "English"),
        Language(code: "es", name: "Spanish"),
        Language(code: "fr", name: "French")
        // Add more languages as needed
    ]
    
    let availableRegions: [Region] = [
        Region(code: "US", name: "United States"),
        Region(code: "GB", name: "United Kingdom"),
        Region(code: "CA", name: "Canada")
        // Add more regions as needed
    ]
    
    let backgroundOptions: [BackgroundOption] = [
        .default,
        .gradient1,
        .gradient2,
        .pattern1,
        .pattern2
    ]
}

// Supporting Types
struct Language: Hashable {
    let code: String
    let name: String
}

struct Region: Hashable {
    let code: String
    let name: String
}

struct BackgroundOption: Identifiable, Equatable {
    let id: String
    let name: String
    let preview: String
    
    static let `default` = BackgroundOption(id: "default", name: "Default", preview: "bg_default")
    static let gradient1 = BackgroundOption(id: "gradient1", name: "Ocean", preview: "bg_gradient1")
    static let gradient2 = BackgroundOption(id: "gradient2", name: "Sunset", preview: "bg_gradient2")
    static let pattern1 = BackgroundOption(id: "pattern1", name: "Dots", preview: "bg_pattern1")
    static let pattern2 = BackgroundOption(id: "pattern2", name: "Waves", preview: "bg_pattern2")
}

struct BackgroundPreviewButton: View {
    let background: BackgroundOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 40)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: isSelected ? 2 : 0)
                    )
                
                Text(background.name)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    NavigationView {
        CustomizationView()
    }
}
