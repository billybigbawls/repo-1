//
//  ProgressView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct ProgressView: View {
    let topAIs: [AI]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            Text("Most Used AIs")
                .font(.title2)
                .fontWeight(.bold)
            
            // Progress Bars
            ForEach(topAIs.prefix(5)) { ai in
                AIProgressRow(
                    ai: ai,
                    progress: calculateProgress(for: ai),
                    messageCount: ai.stats.messagesCount,
                    threshold: calculateThreshold(for: ai.stats.messagesCount)
                )
            }
            
            if topAIs.isEmpty {
                EmptyProgressView()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .glassMorphic()
        )
    }
    
    private func calculateProgress(for ai: AI) -> Double {
        // Calculate progress as percentage of next threshold
        let currentCount = Double(ai.stats.messagesCount)
        let nextThreshold = Double(calculateThreshold(for: ai.stats.messagesCount))
        let previousThreshold = Double(calculatePreviousThreshold(for: ai.stats.messagesCount))
        
        return (currentCount - previousThreshold) / (nextThreshold - previousThreshold)
    }
    
    private func calculateThreshold(for count: Int) -> Int {
        // Thresholds at 50, 100, 250, 500, 1000, etc.
        let thresholds = [50, 100, 250, 500, 1000, 2500, 5000, 10000]
        return thresholds.first { $0 > count } ?? (thresholds.last ?? 0) * 2
    }
    
    private func calculatePreviousThreshold(for count: Int) -> Int {
        let thresholds = [0, 50, 100, 250, 500, 1000, 2500, 5000, 10000]
        return thresholds.last { $0 <= count } ?? 0
    }
}

struct AIProgressRow: View {
    let ai: AI
    let progress: Double
    let messageCount: Int
    let threshold: Int
    @State private var showProgress = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // AI Avatar
                AIAvatar(
                    ai: ai,
                    isSelected: false, // Pass `false` since it's not selected in this context
                    hasNewMessage: false, // No new message indicator needed here
                    isOnCall: false // No call indicator needed here
                )
                .frame(width: 40, height: 40)

                
                VStack(alignment: .leading) {
                    Text(ai.name)
                        .font(.headline)
                    
                    Text("\(messageCount) messages")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Achievement Star
                AchievementStar(level: calculateStarLevel())
                    .frame(width: 30, height: 30)
            }
            
            // Progress Bar
            ProgressBar(progress: showProgress ? progress : 0)
                .frame(height: 8)
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0)) {
                        showProgress = true
                    }
                }
            
            // Progress Text
            Text("\(messageCount)/\(threshold)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    private func calculateStarLevel() -> Int {
        // Calculate star level based on message count
        switch messageCount {
        case 0..<100:
            return 1
        case 100..<500:
            return 2
        case 500..<1000:
            return 3
        case 1000..<5000:
            return 4
        default:
            return 5
        }
    }
}

struct EmptyProgressView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No AI usage data yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Start chatting with AIs to see your progress!")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

#Preview {
    ProgressView(topAIs: [
        AI(id: UUID(),
           name: "Friend AI",
           category: .friend,
           description: "Your AI friend",
           avatar: "",
           backgroundColor: "default",
           isLocked: false,
           stats: AI.AIStats(messagesCount: 75,
                           responseTime: 1.0,
                           userRating: 4.5,
                           lastInteraction: Date()),
           securityEnabled: false)
    ])
    .padding()
    .background(Color.gray.opacity(0.1))
}
