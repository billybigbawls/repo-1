//
//  MainTabView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var tabViewModel = MainTabViewModel()
    @Namespace private var animation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $appState.selectedTab) {
                HomeView()
                    .tag(Tab.home)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                ShopView()
                    .tag(Tab.shop)
                    .tabItem {
                        Label("Shop", systemImage: "bag.fill")
                    }
                
                SettingsView()
                    .tag(Tab.settings)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
            .onChange(of: appState.selectedTab) { newTab in
                tabViewModel.handleTabChange(to: newTab)
            }
            
            // Custom floating AI indicator
            if tabViewModel.showAIIndicator {
                FloatingAIIndicator(
                    currentAI: $appState.currentAI,
                    namespace: animation
                )
                .transition(AnyTransition.move(edge: Edge.bottom).combined(with: .opacity))
            }
        }
        .overlay(
            // Show authentication view if not authenticated
            Group {
                if !appState.isAuthenticated {
                    AuthenticationView()
                        .transition(AnyTransition.opacity)
                }
            }
        )
    }
}

class MainTabViewModel: ObservableObject {
    @Published var showAIIndicator = true
    
    func handleTabChange(to tab: Tab) {
        withAnimation(.spring()) {
            showAIIndicator = tab == .home
        }
    }
}

struct FloatingAIIndicator: View {
    @Binding var currentAI: AI?
    let namespace: Namespace.ID
    
    var body: some View {
        if let ai = currentAI {
            HStack(spacing: 12) {
                // AI Avatar
                Circle()
                    .fill(categoryColor(for: ai.category))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(ai.name.prefix(1))
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                    .matchedGeometryEffect(id: "aiAvatar", in: namespace)
                
                // AI Name and Status
                VStack(alignment: .leading, spacing: 2) {
                    Text(ai.name)
                        .font(.headline)
                    
                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                // Activity indicator
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 1)
                    )
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
    
    private func categoryColor(for category: AI.AICategory) -> Color {
        switch category {
        case .friend:
            return .blue
        case .professional:
            return .purple
        case .creative:
            return .orange
        case .utility:
            return .green
        case .specialist:
            return .yellow
        }
    }
}

enum Tab {
    case home
    case shop
    case settings
}


