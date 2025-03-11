//
//
//  SparkleEffect.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct SparkleEffect: View {
    @Binding var isAnimating: Bool
    let count: Int = 12

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Sparkle particles
                ForEach(0..<count, id: \.self) { _ in
                    // Define the sparkle particle view here
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 3, height: 3)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }
            }
        }
    }
}
