//
//  SquadApp.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

@main
struct SquadApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var themeManager = ThemeManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
                .onAppear {
                    setupAppearance()
                }
        }
    }
    
    private func setupAppearance() {
        // Configure global UI appearance
        UINavigationBar.appearance().tintColor = .systemBlue
        UITabBar.appearance().backgroundColor = .systemBackground
        
        // Configure initial theme
        if let savedTheme = UserDefaults.standard.string(forKey: "theme"),
           let theme = ThemePreference(rawValue: savedTheme) {
            themeManager.currentTheme =
                (theme == .system) ? AppTheme.defaultTheme
                                   : (theme == .dark ? AppTheme.darkTheme
                                                     : AppTheme.defaultTheme)
        }
    }
}

class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentAI: AI?
    @Published var activeSquad: Squad?
    @Published var selectedTab: Tab = .home
    @Published var needsOnboarding = true
    
    init() {
        // Check for existing session
        checkExistingSession()
    }
    
    private func checkExistingSession() {
        // Check if user has completed onboarding
        if UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            needsOnboarding = false
        }
        
        // Check if device has existing auth
        if UserDefaults.standard.string(forKey: "deviceID") != nil {
            isAuthenticated = true
        }
    }
}




#Preview {
    MainTabView()
        .environmentObject(AppState())
        .environmentObject(ThemeManager())
}

