//
//  ThemeManager.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 12/26/24.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    // Original properties
    @Published var colorScheme: ColorScheme = .light
    @Published var currentTheme: AppTheme = AppTheme.defaultTheme
    
    // New properties for background customization
    @Published var chatBackgroundSettings: ChatBackgroundSettings = ChatBackgroundSettings()
    
    // For tracking system theme changes
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load original theme settings
        if let savedScheme = UserDefaults.standard.string(forKey: "colorScheme") {
            colorScheme = savedScheme == "dark" ? .dark : .light
            currentTheme = colorScheme == .dark ? AppTheme.darkTheme : AppTheme.defaultTheme
        }
        
        // Load chat background settings
        chatBackgroundSettings = loadBackgroundSettings()
        
        // Set up a publisher to track system appearance changes if needed
        NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)
            .sink { [weak self] _ in
                // Check for time-based theme changes if needed
            }
            .store(in: &cancellables)
    }
    
    // Original methods
    func toggleColorScheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            colorScheme = (colorScheme == .light) ? .dark : .light
            currentTheme = (colorScheme == .light) ? AppTheme.defaultTheme : AppTheme.darkTheme
            UserDefaults.standard.set(colorScheme == .dark ? "dark" : "light", forKey: "colorScheme")
        }
    }
    
    // New methods for background customization
    func saveBackgroundSettings() {
        // Save category
        UserDefaults.standard.set(chatBackgroundSettings.category.rawValue, forKey: "chatBgCategory")
        
        // Save color settings
        UserDefaults.standard.set(chatBackgroundSettings.colorType.rawValue, forKey: "chatBgColorType")
        if let primaryColorData = try? JSONEncoder().encode(chatBackgroundSettings.primaryColor) {
            UserDefaults.standard.set(primaryColorData, forKey: "chatBgPrimaryColor")
        }
        if let secondaryColor = chatBackgroundSettings.secondaryColor,
           let secondaryColorData = try? JSONEncoder().encode(secondaryColor) {
            UserDefaults.standard.set(secondaryColorData, forKey: "chatBgSecondaryColor")
        } else {
            UserDefaults.standard.removeObject(forKey: "chatBgSecondaryColor")
        }
        
        // Save animation settings
        UserDefaults.standard.set(chatBackgroundSettings.animationType.rawValue, forKey: "chatBgAnimationType")
        
        // Save video settings
        UserDefaults.standard.set(chatBackgroundSettings.videoId, forKey: "chatBgVideoId")
        
        // Save weather settings
        UserDefaults.standard.set(chatBackgroundSettings.isWeatherEnabled, forKey: "chatBgIsWeatherEnabled")
        UserDefaults.standard.set(chatBackgroundSettings.isLocationBasedWeather, forKey: "chatBgIsLocationBasedWeather")
        UserDefaults.standard.set(chatBackgroundSettings.weatherCondition.rawValue, forKey: "chatBgWeatherCondition")
    }
    
    private func loadBackgroundSettings() -> ChatBackgroundSettings {
        var settings = ChatBackgroundSettings()
        
        // Load category
        if let categoryRawValue = UserDefaults.standard.string(forKey: "chatBgCategory"),
           let category = BackgroundCategory(rawValue: categoryRawValue) {
            settings.category = category
        }
        
        // Load color settings
        if let colorTypeRawValue = UserDefaults.standard.integer(forKey: "chatBgColorType") as? Int,
           let colorType = ChatBackgroundSettings.ColorType(rawValue: colorTypeRawValue) {
            settings.colorType = colorType
        }
        
        if let primaryColorData = UserDefaults.standard.data(forKey: "chatBgPrimaryColor"),
           let primaryColor = try? JSONDecoder().decode(Color.self, from: primaryColorData) {
            settings.primaryColor = primaryColor
        }
        
        if let secondaryColorData = UserDefaults.standard.data(forKey: "chatBgSecondaryColor"),
           let secondaryColor = try? JSONDecoder().decode(Color.self, from: secondaryColorData) {
            settings.secondaryColor = secondaryColor
        }
        
        // Load animation settings
        if let animationTypeRawValue = UserDefaults.standard.integer(forKey: "chatBgAnimationType") as? Int,
           let animationType = ChatBackgroundSettings.AnimationType(rawValue: animationTypeRawValue) {
            settings.animationType = animationType
        }
        
        // Load video settings
        settings.videoId = UserDefaults.standard.string(forKey: "chatBgVideoId")
        
        // Load weather settings
        settings.isWeatherEnabled = UserDefaults.standard.bool(forKey: "chatBgIsWeatherEnabled")
        settings.isLocationBasedWeather = UserDefaults.standard.bool(forKey: "chatBgIsLocationBasedWeather")
        
        if let weatherConditionRawValue = UserDefaults.standard.string(forKey: "chatBgWeatherCondition"),
           let weatherCondition = WeatherState.WeatherCondition(rawValue: weatherConditionRawValue) {
            settings.weatherCondition = weatherCondition
        }
        
        return settings
    }
}

// MARK: - Color Codable Extension for background color serialization
extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let r = try container.decode(Double.self, forKey: .red)
        let g = try container.decode(Double.self, forKey: .green)
        let b = try container.decode(Double.self, forKey: .blue)
        let o = try container.decode(Double.self, forKey: .opacity)
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: o)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
        
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
        
        try container.encode(r, forKey: .red)
        try container.encode(g, forKey: .green)
        try container.encode(b, forKey: .blue)
        try container.encode(o, forKey: .opacity)
    }
}
