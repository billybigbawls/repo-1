//
//  ProgressBar.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct ProgressBar: View {
    let progress: Double
    var color: Color = .blue
    var backgroundColor: Color = .gray.opacity(0.2)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(backgroundColor)
                
                // Progress
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(color)
                    .frame(width: max(geometry.size.width * CGFloat(progress), 0))
                
                // Glow effect
                if progress > 0 {
                    RoundedRectangle(cornerRadius: geometry.size.height / 2)
                        .fill(color)
                        .frame(width: max(geometry.size.width * CGFloat(progress), 0))
                        .blur(radius: 4)
                        .opacity(0.3)
                }
                
                // Progress markers
                ForEach(0..<5) { i in
                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 1, height: geometry.size.height)
                        .position(x: geometry.size.width * CGFloat(i + 1) / 5, y: geometry.size.height / 2)
                        .opacity(0.5)
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
        }
    }
}

struct AnimatedProgressBar: View {
    let progress: Double
    let gradient: Gradient
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(Color.gray.opacity(0.2))
                
                // Animated gradient progress
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(
                        LinearGradient(
                            gradient: gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(geometry.size.width * CGFloat(progress), 0))
                    .overlay(
                        RoundedRectangle(cornerRadius: geometry.size.height / 2)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                    .mask(
                        RoundedRectangle(cornerRadius: geometry.size.height / 2)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .white, .clear]),
                                    startPoint: isAnimating ? .leading : .trailing,
                                    endPoint: isAnimating ? .trailing : .leading
                                )
                            )
                    )
            }
        }
        .onAppear {
            withAnimation(
                Animation
                    .linear(duration: 2)
                    .repeatForever(autoreverses: false)
            ) {
                isAnimating = true
            }
        }
    }
}

struct ProgressBarWithLabel: View {
    let progress: Double
    let label: String
    var color: Color = .blue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            ProgressBar(progress: progress, color: color)
                .frame(height: 6)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.7)
            .frame(height: 8)
        
        AnimatedProgressBar(
            progress: 0.8,
            gradient: Gradient(colors: [.blue, .purple])
        )
        .frame(height: 8)
        
        ProgressBarWithLabel(
            progress: 0.6,
            label: "Progress",
            color: .green
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
    .previewLayout(.sizeThatFits)
}
