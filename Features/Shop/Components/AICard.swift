//
//  AICard.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct AICard: View {
    let ai: AI
    let isSelected: Bool
    var onTap: (() -> Void)? = nil
    @State private var showInfo = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                onTap?()
            }
            HapticManager.selection()
        }) {
            VStack(spacing: 12) {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 60, height: 60)
                    
                    Text(ai.name.prefix(1))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                // AI Name
                Text(ai.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                // Info Button
                Button(action: {
                    withAnimation(.spring()) {
                        showInfo = true
                    }
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: isSelected ? .blue.opacity(0.3) : .black.opacity(0.1),
                           radius: isSelected ? 8 : 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(onPress: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = true
            }
        }, onRelease: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = false
            }
        })
        .sheet(isPresented: $showInfo) {
            AIInfoSheet(ai: ai)
        }
    }
    
    private var backgroundColor: Color {
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

struct AIInfoSheet: View {
    let ai: AI
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Circle()
                            .fill(getColor(for: ai.category))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(ai.name.prefix(1))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(ai.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(ai.category.rawValue.capitalized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("About")
                            .font(.headline)
                        
                        Text(ai.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    // Stats
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stats")
                            .font(.headline)
                        
                        StatRow(title: "Messages", value: "\(ai.stats.messagesCount)")
                        StatRow(title: "Response Time", value: String(format: "%.1fs", ai.stats.responseTime))
                        StatRow(title: "Rating", value: String(format: "%.1f", ai.stats.userRating))
                        StatRow(title: "Last Used", value: ai.stats.lastInteraction.timeAgo())
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func getColor(for category: AI.AICategory) -> Color {
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

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// Press gesture handler
extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressActionsModifier(onPress: onPress, onRelease: onRelease))
    }
}

struct PressActionsModifier: ViewModifier {
    let onPress: () -> Void
    let onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

#Preview {
    AICard(
        ai: AI(
            id: UUID(),
            name: "Friend AI",
            category: .friend,
            description: "Your friendly AI companion",
            avatar: "",
            backgroundColor: "default",
            isLocked: false,
            stats: AI.AIStats(
                messagesCount: 100,
                responseTime: 1.2,
                userRating: 4.5,
                lastInteraction: Date()
            ),
            securityEnabled: false
        ),
        isSelected: false
    )
    .frame(width: 150)
    .padding()
}
