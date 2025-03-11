//
//  TypingIndicator.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/28/24.
//

import SwiftUI

struct TypingIndicator: View {
    var isSquad: Bool
    var activeAI: AI?
    @State private var animationOffset: CGFloat = 0
    @State private var opacityValues: [Double] = [1, 0.8, 0.6]
    
    private let numberOfDots = 3
    private let animationDuration: Double = 0.6
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<numberOfDots, id: \.self) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 6, height: 6)
                    .offset(y: animationOffset)
                    .opacity(opacityValues[index])
                    .animation(
                        Animation
                            .easeInOut(duration: animationDuration)
                            .repeatForever()
                            .delay(animationDuration * Double(index) / Double(numberOfDots)),
                        value: animationOffset
                    )
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .glassMorphic()
        )
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(
            Animation
                .easeInOut(duration: animationDuration)
                .repeatForever()
        ) {
            animationOffset = -5
        }
        
        // Animate opacity
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { _ in
            opacityValues.rotate()
        }
    }
}

// Helper extension to rotate array elements
extension Array {
    mutating func rotate() {
        guard count > 1 else { return }
        let lastElement = self[count - 1]
        for i in (1..<count).reversed() {
            self[i] = self[i - 1]
        }
        self[0] = lastElement
    }
}
