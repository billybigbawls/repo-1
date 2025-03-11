//
//  AchievementStar.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct AchievementStar: View {
    let level: Int
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Base star
            StarShape()
                .fill(baseGradient)
                .overlay(
                    StarShape()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
            
            // Glow effect
            if level > 1 {
                StarShape()
                    .fill(glowGradient)
                    .blur(radius: 4)
                    .opacity(0.5)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }
            
            // Level indicator
            Text("\(level)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
    
    private var baseGradient: LinearGradient {
        switch level {
        case 1:
            return LinearGradient(
                colors: [.gray, .gray.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 2:
            return LinearGradient(
                colors: [.bronze, .bronze.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 3:
            return LinearGradient(
                colors: [.silver, .silver.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 4:
            return LinearGradient(
                colors: [.gold, .gold.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [.diamond, .diamond.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var glowGradient: LinearGradient {
        switch level {
        case 2:
            return LinearGradient(
                colors: [.bronze.opacity(0.5), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 3:
            return LinearGradient(
                colors: [.silver.opacity(0.5), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 4:
            return LinearGradient(
                colors: [.gold.opacity(0.5), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [.diamond.opacity(0.5), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * 0.4
        let points = 5
        
        var path = Path()
        
        for i in 0..<points * 2 {
            let angle = Double(i) * .pi / Double(points)
            let r = i % 2 == 0 ? radius : innerRadius
            let x = center.x + CGFloat(cos(angle)) * r
            let y = center.y + CGFloat(sin(angle)) * r
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.closeSubpath()
        return path
    }
}

// Custom colors for achievement levels
extension Color {
    static let bronze = Color(red: 0.8, green: 0.5, blue: 0.2)
    static let silver = Color(red: 0.75, green: 0.75, blue: 0.75)
    static let gold = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let diamond = Color(red: 0.6, green: 0.8, blue: 1.0)
}

struct AchievementStarRow: View {
    let level: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            AchievementStar(level: level)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
                .glassMorphic()
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            ForEach(1...5, id: \.self) { level in
                AchievementStar(level: level)
                    .frame(width: 40, height: 40)
            }
        }
        
        AchievementStarRow(
            level: 3,
            title: "Silver Achiever",
            description: "Reached 500 messages with this AI"
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
    .previewLayout(.sizeThatFits)
}
