//
//  ShopView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI
import Lottie

struct ShopView: View {
    @StateObject private var viewModel = ShopViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.lightBlue, .pastelTan, .pastelPink]),
                startPoint: .trailing,
                endPoint: .leading
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Shop Title
                    Text("SHOP")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    // Shopkeeper Animation
                    ShopkeeperView(animation: viewModel.shopkeeperAnimation)
                        .frame(height: 200)
                        .padding(.vertical)
                    
                    // Categories
                    CategoryView(
                        categories: viewModel.categories,
                        selectedCategory: $viewModel.selectedCategory
                    )
                    
                    // Squad Link-up Section
                    SquadLinkUpPreview(
                        selectedAIs: $viewModel.selectedAIs,
                        availableAIs: viewModel.filteredAIs,
                        onSquadCreated: viewModel.handleSquadCreation
                    )
                    .padding(.horizontal)
                    
                    // Progress Section
                    ProgressView(topAIs: viewModel.topUsedAIs)
                        .padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
        }
        .onChange(of: viewModel.selectedCategory) { _ in
            withAnimation {
                viewModel.filterAIs()
            }
        }
    }
}

struct SquadLinkUpPreview: View {
    @Binding var selectedAIs: Set<AI>
    let availableAIs: [AI]
    let onSquadCreated: (Squad) -> Void
    @State private var showFullSquadLinkUp = false
    @State private var showNameInput = false
    @State private var squadName = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Squad Groupchats")
                .font(.title2)
                .fontWeight(.bold)
            
            // Preview of selected AIs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(selectedAIs), id: \.id) { ai in
                        AICard(ai: ai, isSelected: true) {
                            selectedAIs.remove(ai)
                        }
                        .frame(width: 100, height: 140)
                    }
                    
                    if selectedAIs.count < 3 {
                        Button(action: { showFullSquadLinkUp = true }) {
                            VStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 30))
                                Text("Add AI")
                                    .font(.caption)
                            }
                            .frame(width: 100, height: 140)
                            .background(Color.white.opacity(0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            
            if selectedAIs.count >= 2 {
                Button(action: { showNameInput = true }) {
                    Text("Create Squad")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .sheet(isPresented: $showFullSquadLinkUp) {
            NavigationView {
                SquadLinkUpView(selectedAIs: $selectedAIs, availableAIs: availableAIs)
            }
        }
        .sheet(isPresented: $showNameInput) {
            NavigationView {
                SquadNamingView(
                    name: $squadName,
                    selectedAIs: Array(selectedAIs)
                ) {
                    createSquad()
                }
            }
        }
    }
    
    private func createSquad() {
        guard !squadName.isEmpty && selectedAIs.count >= 2 else { return }
        
        let squad = Squad(
            id: UUID(),
            name: squadName,
            members: Array(selectedAIs),
            createdAt: Date(),
            lastActive: Date(),
            avatar: "squad_default",
            stats: Squad.SquadStats(
                totalInteractions: 0,
                averageResponseTime: 0,
                popularity: 0
            )
        )
        
        // Convert squad to special AI type
        let squadAI = AI(
            id: squad.id,
            name: squad.name,
            category: .specialist, // or create new category for squads
            description: "Cuurent Squad \(selectedAIs.count) AIs",
            avatar: squad.avatar,
            backgroundColor: "default",
            isLocked: false,
            stats: AI.AIStats(
                messagesCount: 0,
                responseTime: 0,
                userRating: 0,
                lastInteraction: Date()
            ),
            securityEnabled: false,
            isSquad: true,
            squadMembers: Array(selectedAIs)
        )
        
        // Call back to view model
        onSquadCreated(squad)
        
        // Reset state
        squadName = ""
        selectedAIs.removeAll()
        showNameInput = false
    }
}

private class ShopViewModel: ObservableObject {
    @Published var categories: [AI.AICategory] = []
    @Published var selectedCategory: AI.AICategory?
    @Published var availableAIs: [AI] = []
    @Published var selectedAIs: Set<AI> = []
    @Published var topUsedAIs: [AI] = []
    @Published var shopkeeperAnimation: String = "shopkeeper_wave"
    @Published private(set) var filteredAIs: [AI] = []
    
    private let aiManager = AIManager.shared
    
    init() {
        loadData()
    }
    
    func handleSquadCreation(_ squad: Squad) {
        // Convert squad to AI and add to available AIs
        let squadAI = convertSquadToAI(squad)
        availableAIs.append(squadAI)
        filterAIs()
        
        // Notify AI manager
        aiManager.addNewAI(squadAI)
    }
    
    private func convertSquadToAI(_ squad: Squad) -> AI {
        return AI(
            id: squad.id,
            name: squad.name,
            category: .specialist,
            description: "Squad of \(squad.members.count) AIs",
            avatar: squad.avatar,
            backgroundColor: "default",
            isLocked: false,
            stats: AI.AIStats(
                messagesCount: 0,
                responseTime: 0,
                userRating: 0,
                lastInteraction: Date()
            ),
            securityEnabled: false,
            isSquad: true,
            squadMembers: squad.members
        )
    }
    
    private func loadData() {
        categories = AI.AICategory.allCases
        // Load AIs, top used AIs, etc.
    }
    
    func filterAIs() {
        if let category = selectedCategory {
            filteredAIs = availableAIs.filter { $0.category == category }
        } else {
            filteredAIs = availableAIs
        }
    }
}

struct SquadNamingView: View {
    @Binding var name: String
    let selectedAIs: [AI]
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Name Your Squad")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("Enter squad name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Selected AIs preview
            VStack(alignment: .leading) {
                Text("Squad Members")
                    .font(.headline)
                
                ForEach(selectedAIs) { ai in
                    Text("• \(ai.name)")
                        .padding(.vertical, 4)
                }
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationBarItems(
            leading: Button("Cancel") { dismiss() },
            trailing: Button("Create") {
                onSave()
                dismiss()
            }
            .disabled(name.isEmpty)
        )
    }
}


#Preview {
    ShopView()
}
