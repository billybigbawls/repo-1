//
//  SelectedAIIndicator.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct SelectedAIIndicator: View {
    let ai: AI
    let onRemove: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Main AI indicator
            VStack(spacing: 8) {
                // Avatar
                Circle()
                    .fill(categoryColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(ai.name.prefix(1))
                            .font(.headline)
                            .foregroundColor(categoryColor)
                    )
                    .overlay(
                        Circle()
                            .stroke(categoryColor, lineWidth: 2)
                            .opacity(0.5)
                    )
                
                // Name
                Text(ai.name)
                    .font(.caption)
                    .lineLimit(1)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .glassMorphic()
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(categoryColor.opacity(0.3), lineWidth: 1)
            )
            
            // Remove button
            Button(action: {
                withAnimation(.spring()) {
                    onRemove()
                }
                HapticManager.impact(style: .light)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .background(Circle().fill(Color.white))
                    .offset(x: 6, y: -6)
            }
            .opacity(isHovered ? 1 : 0.7)
        }
        .onHover(perform: { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        })
        .transition(.scale.combined(with: .opacity))
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

// Extension for hover support on iOS
extension View {
    func onHover(_ action: @escaping (Bool) -> Void) -> some View {
        #if os(iOS)
        return self // No-op on iOS
        #else
        return onHover(perform: action)
        #endif
    }
}

// Optional animation when removing
struct RemoveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    HStack {
        SelectedAIIndicator(
            ai: AI(
                id: UUID(),
                name: "Friend AI",
                category: .friend,
                description: "Your friendly AI",
                avatar: "",
                backgroundColor: "default",
                isLocked: false,
                stats: AI.AIStats(
                    messagesCount: 0,
                    responseTime: 0,
                    userRating: 0,
                    lastInteraction: Date()
                ),
                securityEnabled: false
            ),
            onRemove: {}
        )
        
        SelectedAIIndicator(
            ai: AI(
                id: UUID(),
                name: "Pro AI",
                category: .professional,
                description: "Professional AI",
                avatar: "",
                backgroundColor: "default",
                isLocked: false,
                stats: AI.AIStats(
                    messagesCount: 0,
                    responseTime: 0,
                    userRating: 0,
                    lastInteraction: Date()
                ),
                securityEnabled: false
            ),
            onRemove: {}
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
