//
//  SquadLinkUpView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct SquadLinkUpView: View {
    @Binding var selectedAIs: Set<AI>
    let availableAIs: [AI]
    @State private var searchText = ""
    @State private var squadName = ""
    @State private var isNaming = false
    @State private var showSuccessAnimation = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Title and description
            VStack(spacing: 8) {
                Text("Squad Link-up")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Select up to 3 AIs to create a squad")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            // Selected AIs preview
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Array(selectedAIs), id: \.id) { ai in
                        SelectedAIIndicator(
                            ai: ai,
                            onRemove: { removeAI(ai) }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: selectedAIs.isEmpty ? 0 : 80)
            
            // Squad Formation Animation
            if !selectedAIs.isEmpty {
                SquadPreviewView(ais: Array(selectedAIs))
                    .frame(height: 200)
                
                if selectedAIs.count >= 2 {
                    Button(action: { isNaming = true }) {
                        Text("Squad Link-up")
                            .withSystemSound(.success, haptic: true)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                                    .overlay(
                                        SparkleEffect(isAnimating: $showSuccessAnimation)
                                            .opacity(showSuccessAnimation ? 1 : 0)
                                    )
                            )
                    }
                    .padding(.horizontal)
                }
            }
            
            // Search and results
            SquadSearchView(
                searchText: $searchText,
                availableAIs: availableAIs,
                selectedAIs: $selectedAIs,
                onSelect: selectAI
            )
        }
        .sheet(isPresented: $isNaming) {
            SquadNamingSheet(
                name: $squadName,
                selectedAIs: Array(selectedAIs),
                onSave: createSquad
            )
        }
    }
    
    private func selectAI(_ ai: AI) {
        guard selectedAIs.count < 3 else { return }
        SystemSound.playForAISelection()
        withAnimation(.spring()) {
            selectedAIs.insert(ai)
        }
        HapticManager.selection()
    }
    
    private func removeAI(_ ai: AI) {
        SystemSound.playForMessage(sent: false)
        withAnimation(.spring()) {
            selectedAIs.remove(ai)
        }
        HapticManager.impact(style: .light)
    }
    
    private func createSquad() {
        guard !squadName.isEmpty && selectedAIs.count >= 2 else {
            SoundManager.shared.play(.error)
            return
        }
        
        SystemSound.playForSquadCreation()  // Add this line
        withAnimation(.spring()) {
            showSuccessAnimation = true
        }
        
        // Show success animation and haptic
        HapticManager.success()
        
        // Reset after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showSuccessAnimation = false
                isNaming = false
                squadName = ""
                selectedAIs.removeAll()
            }
        }
    }
}

struct SquadNamingSheet: View {
    @Binding var name: String
    let selectedAIs: [AI]
    let onSave: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Squad preview
                SquadCircleAnimation(ais: selectedAIs)
                    .frame(height: 200)
                
                // Name input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Squad Name")
                        .font(.headline)
                    
                    TextField("Enter squad name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                }
                
                // Selected AIs list
                VStack(alignment: .leading, spacing: 8) {
                    Text("Squad Members")
                        .font(.headline)
                    
                    ForEach(selectedAIs) { ai in
                        HStack {
                            Text("• \(ai.name)")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitle("Name Your Squad", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Create") {
                    onSave()
                }
                    .withSystemSound(.success, haptic: true)
                .disabled(name.isEmpty)
            )
        }
    }
}

#Preview {
    SquadLinkUpView(
        selectedAIs: .constant([]),
        availableAIs: [
            AI(id: UUID(), name: "Friend AI", category: .friend, description: "Your friendly AI", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
            AI(id: UUID(), name: "Pro AI", category: .professional, description: "Professional AI", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false)
        ]
    )
}
