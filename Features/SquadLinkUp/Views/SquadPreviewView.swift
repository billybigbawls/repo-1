//
//  SquadPreviewView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct SquadPreviewView: View {
    let ais: [AI]
    @State private var isAnimating = false
    @State private var showCompatibility = false
    
    var body: some View {
        ZStack {
            // Background circles
            ForEach(0..<3) { index in
                Circle()
                    .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                    .scaleEffect(isAnimating ? 1 + Double(index) * 0.2 : 0.8)
                    .opacity(isAnimating ? 0.0 : 0.5)
            }
            
            // Connection lines between AIs
            ForEach(0..<ais.count, id: \.self) { index in
                ForEach((index + 1)..<ais.count, id: \.self) { nextIndex in
                    ConnectionLine(
                        from: position(for: index, count: ais.count),
                        to: position(for: nextIndex, count: ais.count),
                        compatibility: calculateCompatibility(ais[index], ais[nextIndex])
                    )
                    .opacity(showCompatibility ? 1 : 0)
                }
            }
            
            // AI Avatars
            ForEach(Array(ais.enumerated()), id: \.element.id) { index, ai in
                AIPreviewAvatar(
                    ai: ai,
                    position: position(for: index, count: ais.count),
                    isAnimating: isAnimating
                )
            }
            
            // Center spark effect when complete
            if ais.count >= 2 {
                SparkleEffect(isAnimating: $isAnimating)
                    .opacity(isAnimating ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
            withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
                showCompatibility = true
            }
        }
    }
    
    private func position(for index: Int, count: Int) -> CGPoint {
        let radius: CGFloat = 80
        let angle = (2 * .pi / CGFloat(count)) * CGFloat(index) - .pi / 2
        return CGPoint(
            x: cos(angle) * radius + 100,
            y: sin(angle) * radius + 100
        )
    }
    
    private func calculateCompatibility(_ ai1: AI, _ ai2: AI) -> Double {
        // Mock compatibility calculation
        // In real app, this would be based on actual AI characteristics
        return Double.random(in: 0.5...1.0)
    }
}

struct AIPreviewAvatar: View {
    let ai: AI
    let position: CGPoint
    let isAnimating: Bool
    
    var body: some View {
        Circle()
            .fill(categoryColor)
            .frame(width: 50, height: 50)
            .overlay(
                Text(ai.name.prefix(1))
                    .font(.headline)
                    .foregroundColor(.white)
            )
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .opacity(0.5)
            )
            .position(position)
            .scaleEffect(isAnimating ? 1 : 0)
            .shadow(color: categoryColor.opacity(0.5), radius: isAnimating ? 10 : 0)
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

struct ConnectionLine: View {
    let from: CGPoint
    let to: CGPoint
    let compatibility: Double
    @State private var progress: CGFloat = 0
    
    var body: some View {
        Path { path in
            path.move(to: from)
            path.addLine(to: to)
        }
        .trim(from: 0, to: progress)
        .stroke(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .leading,
                endPoint: .trailing
            ),
            style: StrokeStyle(
                lineWidth: 2,
                lineCap: .round,
                dash: [4, 4]
            )
        )
        .opacity(compatibility)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                progress = 1
            }
        }
    }
}

#Preview {
    SquadPreviewView(ais: [
        AI(id: UUID(), name: "Friend AI", category: .friend, description: "Your friendly AI", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
        AI(id: UUID(), name: "Pro AI", category: .professional, description: "Professional AI", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
        AI(id: UUID(), name: "Creative AI", category: .creative, description: "Creative AI", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false)
    ])
    .frame(width: 300, height: 300)
    .background(Color.gray.opacity(0.1))
}
