//
//  HomeView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.lightBlue, .pastelTan, .pastelPink]),
                startPoint: .trailing,
                endPoint: .leading
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top Navigation
                TopNavigationBar(
                    currentAI: $viewModel.currentAI,
                    onShopTapped: { appState.selectedTab = .shop },
                    onSettingsTapped: { appState.selectedTab = .settings }
                )
                // Search Bar
                SearchBar(text: $searchText)
                    .padding(.horizontal, 60)
                    .padding(.vertical, 10)


                
                // Chat View
                ChatView(
                    messages: $viewModel.messages,
                    isTyping: $viewModel.isTyping,
                    backgroundType: viewModel.currentAI?.backgroundColor ?? "default",
                    currentAI: viewModel.currentAI ?? AI.createIndividual(  // Provide default AI
                        name: "Default",
                        category: .utility,
                        description: "Default AI"
                    )
                )
                
                // AI Wheel
                AIWheelView(
                    ais: viewModel.availableAIs,
                    selectedAI: $viewModel.currentAI,
                    onAISelected: viewModel.handleAISelection
                )
                .frame(height: 120)
                .padding(.bottom)
            }
        }
        .onChange(of: searchText) { newValue in
            viewModel.filterMessages(searchText: newValue)
        }
    }
}

struct TopNavigationBar: View {
    @Binding var currentAI: AI?
    let onShopTapped: () -> Void
    let onSettingsTapped: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onShopTapped) {
                Image(systemName: "cart.fill")
                    .font(.title2)
            }
            
            Spacer()
            
            Text(currentAI?.name ?? "Select AI")
                .font(Constants.Font.headline)
                .opacity(0.8)
            
            Spacer()
            
            Button(action: onSettingsTapped) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
            }
        }
        .padding()
        .foregroundColor(.primary)
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
    }
}
#Preview {
    HomeView()
}
