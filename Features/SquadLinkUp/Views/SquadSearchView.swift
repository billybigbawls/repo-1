//
//  SquadSearchView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct SquadSearchView: View {
    @Binding var searchText: String
    let availableAIs: [AI]
    @Binding var selectedAIs: Set<AI>
    let onSelect: (AI) -> Void
    
    @State private var selectedCategory: AI.AICategory?
    @State private var isSearching = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("Find AI for Squad", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onTapGesture {
                        withAnimation {
                            isSearching = true
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.1))
                    .glassMorphic()
            )
            .padding(.horizontal)
            
            // Category filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryFilterButton(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        onTap: { selectedCategory = nil }
                    )
                    
                    ForEach(AI.AICategory.allCases, id: \.self) { category in
                        CategoryFilterButton(
                            title: category.displayName,
                            isSelected: selectedCategory == category,
                            onTap: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Results
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 150), spacing: 16)
                    ],
                    spacing: 16
                ) {
                    ForEach(filteredAIs) { ai in
                        AISearchCard(
                            ai: ai,
                            isSelected: selectedAIs.contains(ai),
                            onSelect: { onSelect(ai) }
                        )
                    }
                }
                .padding()
            }
        }
    }
    
    private var filteredAIs: [AI] {
        var filtered = availableAIs
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply search text filter
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
}

struct CategoryFilterButton: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                onTap()
            }
            HapticManager.selection()
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.white.opacity(0.1))
                )
        }
    }
}

struct AISearchCard: View {
    let ai: AI
    let isSelected: Bool
    let onSelect: () -> Void
    
    @State private var showInfo = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if !isSelected {
                onSelect()
            }
        }) {
            VStack(spacing: 12) {
                // AI Avatar
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(ai.name.prefix(1))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(categoryColor)
                    )
                
                // AI Name
                Text(ai.name)
                    .font(.headline)
                    .lineLimit(1)
                
                // Category
                Text(ai.category.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Info Button
                Button(action: { showInfo = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .glassMorphic()
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .opacity(isSelected ? 0.7 : 1.0)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(
            onPress: { withAnimation { isPressed = true } },
            onRelease: { withAnimation { isPressed = false } }
        )
        .sheet(isPresented: $showInfo) {
            AIInfoSheet(ai: ai)
        }
    }
    
    private var categoryColor: Color {
        switch ai.category {
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

#Preview {
    SquadSearchView(
        searchText: .constant(""),
        availableAIs: [
            AI(id: UUID(), name: "Friend AI", category: .friend, description: "Your friendly AI", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
            AI(id: UUID(), name: "Pro AI", category: .professional, description: "Professional AI", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false)
        ],
        selectedAIs: .constant([]),
        onSelect: { _ in }
    )
}
