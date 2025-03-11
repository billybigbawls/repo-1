//
//  SquadCircleAnimation.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI
import Foundation

struct SquadCircleAnimation: View {
    let ais: [AI]
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 0
    @State private var connectionOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background circles
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.blue.opacity(0.1), lineWidth: 1)
                        .scaleEffect(scale * (1 + Double(i) * 0.1))
                }
                
                // Connection lines
                ForEach(0..<ais.count, id: \.self) { index in
                    ForEach((index + 1)..<ais.count, id: \.self) { nextIndex in
                        ConnectingLine(
                            from: position(for: index, in: geometry.size),
                            to: position(for: nextIndex, in: geometry.size),
                            progress: connectionOpacity
                        )
                    }
                }
                
                // AI Avatars
                ForEach(Array(ais.enumerated()), id: \.element.id) { index, ai in
                    RotatingAIAvatar(
                        ai: ai,
                        position: position(for: index, in: geometry.size),
                        rotation: rotation,
                        scale: scale
                    )
                }
                
                // Center energy effect
                if !ais.isEmpty {
                    CenterEnergyEffect(isAnimating: scale > 0.5)
                        .opacity(connectionOpacity)
                }
            }
            .onAppear {
                animateIn()
            }
        }
    }
    
    private func position(for index: Int, in size: CGSize) -> CGPoint {
        let radius = min(size.width, size.height) * 0.35
        let angle = (2 * .pi / Double(ais.count)) * Double(index) + rotation
        return CGPoint(
            x: size.width/2 + Foundation.cos(angle) * radius,
            y: size.height/2 + sin(angle) * radius
        )
    }
    
    private func animateIn() {
        withAnimation(.easeOut(duration: 1.0)) {
            scale = 1
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
            rotation = .pi * 2
        }
        
        withAnimation(.easeIn(duration: 0.8).delay(0.2)) {
            connectionOpacity = 1
        }
    }
}

struct RotatingAIAvatar: View {
    let ai: AI
    let position: CGPoint
    let rotation: Double
    let scale: CGFloat
    
    var body: some View {
        Circle()
            .fill(categoryGradient)
            .frame(width: 50, height: 50)
            .overlay(
                Text(ai.name.prefix(1))
                    .font(.headline)
                    .foregroundColor(.white)
            )
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
            )
            .shadow(color: categoryColor.opacity(0.5), radius: 5)
            .position(position)
            .scaleEffect(scale)
            .rotation3DEffect(.degrees(-rotation * 180 / .pi), axis: (x: 0, y: 0, z: 1))
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
    
    private var categoryGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [categoryColor, categoryColor.opacity(0.7)]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct ConnectingLine: View {
    let from: CGPoint
    let to: CGPoint
    let progress: Double
    @State private var dashPhase: CGFloat = 0
    
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
                dash: [4, 4],
                dashPhase: dashPhase
            )
        )
        .onAppear {
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                dashPhase -= 8
            }
        }
    }
}

struct CenterEnergyEffect: View {
    let isAnimating: Bool
    @State private var scale: CGFloat = 0.8
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                    .scaleEffect(scale * (1 + Double(i) * 0.1))
                    .rotationEffect(.degrees(rotation * Double(i + 1)))
                    .opacity(0.3)
            }
        }
        .onAppear {
            guard isAnimating else { return }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    SquadCircleAnimation(ais: [
        AI(id: UUID(), name: "Friend", category: .friend, description: "", avatar: "", backgroundColor: "", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
        AI(id: UUID(), name: "Pro", category: .professional, description: "", avatar: "", backgroundColor: "", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
        AI(id: UUID(), name: "Creative", category: .creative, description: "", avatar: "", backgroundColor: "", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false)
    ])
    .frame(height: 300)
    .background(Color.gray.opacity(0.1))
}
