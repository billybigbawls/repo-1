//
//  ChatBackgroundSettingsView.swift
//  Squad
//
//  Created for Squad App
//

import SwiftUI
import CoreLocation

struct ChatBackgroundSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var selectedCategory: BackgroundCategory = .color
    @State private var settings = ChatBackgroundSettings()
    @State private var showInfoTooltip: Bool = false
    @State private var showingLocationPermissionAlert: Bool = false
    
    private let colorOptions: [(Color, String)] = [
        (.blue, "Blue"),
        (.purple, "Purple"),
        (.green, "Green"),
        (.orange, "Orange"),
        (.pink, "Pink"),
        (.gray, "Gray")
    ]
    
    private let animationOptions: [(ChatBackgroundSettings.AnimationType, String, String)] = [
        (.bubbles, "Bubbles", "circle.grid.3x3.fill"),
        (.dots, "Dots", "circle.grid.2x2.fill"),
        (.waves, "Waves", "waveform")
    ]
    
    private let videoOptions: [(String, String)] = [
        ("ocean", "Ocean Waves"),
        ("fireplace", "Fireplace"),
        ("rain", "Rainfall"),
        ("stars", "Starry Night")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Category selector
                categorySelector
                
                // Divider
                Divider()
                    .padding(.horizontal)
                
                // Content for selected category
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Preview
                        previewSection
                        
                        // Category-specific options
                        switch selectedCategory {
                        case .irl:
                            irlSection
                        case .color:
                            colorSection
                        case .animated:
                            animatedSection
                        case .video:
                            videoSection
                        }
                        
                        // Apply button
                        Button(action: saveSettings) {
                            Text("Apply Changes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.appPrimary)
                                .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationTitle("Chat Background")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                loadCurrentSettings()
            }
            .alert("Location Access Required", isPresented: $showingLocationPermissionAlert) {
                Button("Cancel", role: .cancel) {
                    settings.isLocationBasedWeather = false
                }
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please allow location access in Settings to use real-world weather backgrounds.")
            }
        }
    }
    
    // MARK: - View Sections
    
    private var categorySelector: some View {
        HStack(spacing: 0) {
            categoryButton(.irl, title: "IRL")
            categoryButton(.color, title: "Color")
            categoryButton(.animated, title: "Animated")
            categoryButton(.video, title: "Video")
        }
        .padding(.vertical, 8)
    }
    
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Preview")
                .font(.headline)
                .foregroundColor(.primary)
            
            ZStack {
                // Preview of the selected background
                ChatBackgroundView(settings: settings)
                    .frame(height: 200)
                    .cornerRadius(16)
                
                // Sample chat bubbles
                VStack {
                    HStack {
                        Spacer()
                        Text("Hello! How's it going?")
                            .padding()
                            .background(Color.appPrimary)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .padding(.trailing)
                    }
                    
                    HStack {
                        Text("I love the new background!")
                            .padding()
                            .background(Color.secondaryBackground)
                            .foregroundColor(.primary)
                            .cornerRadius(16)
                            .padding(.leading)
                        Spacer()
                    }
                }
                .padding()
            }
            .frame(height: 200)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private var irlSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle(isOn: $settings.isWeatherEnabled) {
                Text("Weather Effects")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.appPrimary))
            
            if settings.isWeatherEnabled {
                // Location-based weather toggle
                HStack {
                    Toggle(isOn: $settings.isLocationBasedWeather) {
                        HStack {
                            Text("IRL Weather")
                                .font(.subheadline)
                            
                            Button(action: {
                                withAnimation { showInfoTooltip.toggle() }
                            }) {
                                Image(systemName: "info.circle")
                                    .font(.caption)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color.appPrimary))
                    .onChange(of: settings.isLocationBasedWeather) { newValue in
                        if newValue {
                            checkLocationPermission()
                        }
                    }
                }
                
                if showInfoTooltip {
                    Text("Uses your current location to display weather effects that match real-world conditions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color.secondaryBackground)
                        .cornerRadius(8)
                        .transition(.opacity)
                }
                
                if !settings.isLocationBasedWeather {
                    Text("Select Weather")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .padding(.top, 8)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(WeatherState.WeatherCondition.allCases, id: \.self) { condition in
                            weatherConditionButton(condition)
                        }
                    }
                }
            }
        }
    }
    
    private var colorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Color Type")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                colorTypeButton(.solid, title: "Solid")
                colorTypeButton(.gradient, title: "Gradient")
            }
            
            Text("Primary Color")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 8)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(colorOptions, id: \.0) { color, name in
                    colorButton(color, name: name, isSelected: settings.primaryColor == color) {
                        settings.primaryColor = color
                    }
                }
            }
            
            if settings.colorType == .gradient {
                Text("Secondary Color")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.top, 8)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(colorOptions, id: \.0) { color, name in
                        colorButton(color, name: name, isSelected: settings.secondaryColor == color) {
                            settings.secondaryColor = color
                        }
                    }
                }
            }
        }
    }
    
    private var animatedSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Animation Type")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(animationOptions, id: \.0) { type, name, icon in
                    animationTypeButton(type, title: name, icon: icon)
                }
            }
            
            // Background color for animation
            Text("Background Color")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 8)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(colorOptions, id: \.0) { color, name in
                    colorButton(color, name: name, isSelected: settings.primaryColor == color) {
                        settings.primaryColor = color
                    }
                }
            }
        }
    }
    
    private var videoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Video")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [GridItem(.flexible())], spacing: 12) {
                ForEach(videoOptions, id: \.0) { id, name in
                    videoButton(id, name: name)
                }
            }
            
            // Overlay color
            Text("Overlay Color")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 8)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(colorOptions, id: \.0) { color, name in
                    colorButton(color, name: name, isSelected: settings.primaryColor == color) {
                        settings.primaryColor = color
                    }
                }
            }
            
            // Adjust opacity slider
            if settings.primaryColor != .clear {
                HStack {
                    Text("Opacity")
                        .font(.subheadline)
                    
                    Slider(value: Binding(
                        get: { Color.getOpacity(settings.primaryColor) },
                        set: { settings.primaryColor = settings.primaryColor.opacity($0) }
                    ), in: 0.1...0.5)
                    
                    Text("\(Int(Color.getOpacity(settings.primaryColor) * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
    }
    
    // MARK: - Helper Views
    
    private func categoryButton(_ category: BackgroundCategory, title: String) -> some View {
        Button(action: {
            withAnimation {
                selectedCategory = category
                settings.category = category
                updateSettingsForCategory()
                HapticManager.playLight()
            }
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(selectedCategory == category ? .semibold : .regular)
                .foregroundColor(selectedCategory == category ? .appPrimary : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    selectedCategory == category ?
                    Color.appPrimary.opacity(0.1) : Color.clear
                )
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(selectedCategory == category ? .appPrimary : .clear)
                        .offset(y: 17),
                    alignment: .bottom
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func weatherConditionButton(_ condition: WeatherState.WeatherCondition) -> some View {
        let iconName: String
        let title: String
        
        switch condition {
        case .clear:
            iconName = "sun.max.fill"
            title = "Clear"
        case .rain:
            iconName = "cloud.rain.fill"
            title = "Rain"
        case .snow:
            iconName = "cloud.snow.fill"
            title = "Snow"
        case .cloudy:
            iconName = "cloud.fill"
            title = "Cloudy"
        }
        
        return Button(action: {
            withAnimation {
                settings.weatherCondition = condition
                HapticManager.playLight()
            }
        }) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundColor(Color.appPrimary)
                
                Text(title)
                    .font(.subheadline)
                
                Spacer()
                
                if settings.weatherCondition == condition {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.appPrimary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(settings.weatherCondition == condition ?
                          Color.appPrimary.opacity(0.1) :
                          Color.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(settings.weatherCondition == condition ?
                            Color.appPrimary :
                            Color.clear,
                            lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func colorTypeButton(_ type: ChatBackgroundSettings.ColorType, title: String) -> some View {
        Button(action: {
            withAnimation {
                settings.colorType = type
                HapticManager.playLight()
            }
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(settings.colorType == type ? .semibold : .regular)
                .foregroundColor(settings.colorType == type ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(settings.colorType == type ? Color.appPrimary : Color.secondaryBackground)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func colorButton(_ color: Color, name: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation {
                action()
                HapticManager.playLight()
            }
        }) {
            VStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: isSelected ? 2 : 0)
                    )
                    .shadow(radius: 2)
                
                Text(name)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func animationTypeButton(_ type: ChatBackgroundSettings.AnimationType, title: String, icon: String) -> some View {
        Button(action: {
            withAnimation {
                settings.animationType = type
                HapticManager.playLight()
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(Color.appPrimary)
                
                Text(title)
                    .font(.subheadline)
                
                Spacer()
                
                if settings.animationType == type {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.appPrimary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(settings.animationType == type ?
                          Color.appPrimary.opacity(0.1) :
                          Color.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(settings.animationType == type ?
                            Color.appPrimary :
                            Color.clear,
                            lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func videoButton(_ id: String, name: String) -> some View {
        Button(action: {
            withAnimation {
                settings.videoId = id
                HapticManager.playLight()
            }
        }) {
            HStack {
                Image(systemName: "video.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color.appPrimary)
                
                Text(name)
                    .font(.subheadline)
                
                Spacer()
                
                if settings.videoId == id {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.appPrimary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(settings.videoId == id ?
                          Color.appPrimary.opacity(0.1) :
                          Color.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(settings.videoId == id ?
                            Color.appPrimary :
                            Color.clear,
                            lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helper Methods
    
    private func checkLocationPermission() {
        LocationService.shared.checkLocationAuthorization { authorized in
            if !authorized {
                DispatchQueue.main.async {
                    settings.isLocationBasedWeather = false
                    showingLocationPermissionAlert = true
                }
            }
        }
    }
    
    private func updateSettingsForCategory() {
        // Set appropriate defaults when switching categories
        switch settings.category {
        case .irl:
            // Don't change weather settings
            break
        case .color:
            // Ensure we have colors set
            if settings.primaryColor == .clear {
                settings.primaryColor = .appBackground
            }
            break
        case .animated:
            // Ensure animation type is set
            break
        case .video:
            // Set default video if none selected
            if settings.videoId == nil {
                settings.videoId = videoOptions.first?.0
            }
            break
        }
    }
    
    // MARK: - Data Methods
    
    private func loadCurrentSettings() {
        // Load settings from ThemeManager
        settings = themeManager.chatBackgroundSettings
        selectedCategory = settings.category
    }
    
    private func saveSettings() {
        // Save settings to ThemeManager
        themeManager.chatBackgroundSettings = settings
        themeManager.saveBackgroundSettings()
        
        HapticManager.playSuccess()
        dismiss()
    }
}

extension Color {
    static func getOpacity(_ color: Color) -> Double {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        UIColor(color).getRed(&r, green: &g, blue: &b, alpha: &o)
        return Double(o)
    }
}

struct ChatBackgroundSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatBackgroundSettingsView()
            .environmentObject(ThemeManager())
    }
}
