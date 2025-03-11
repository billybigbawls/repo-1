//
//  Animations.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

enum Animations {
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.3)
    
    static let sparkle = Animation
        .easeInOut(duration: 0.6)
        .repeatCount(3, autoreverses: true)
    
    static let rotation = Animation
        .linear(duration: 2.0)
        .repeatForever(autoreverses: false)
    
    static let pulse = Animation
        .easeInOut(duration: 1.0)
        .repeatForever(autoreverses: true)
    
    static let bounce = Animation
        .interpolatingSpring(stiffness: 170, damping: 15)
    
    static let slideIn = Animation
        .spring(response: 0.35, dampingFraction: 0.85, blendDuration: 0.3)
    
    static let popIn = Animation
        .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3)
    
    struct AnimationModifier: ViewModifier {
        let animation: Animation
        @Binding var trigger: Bool
        
        func body(content: Content) -> some View {
            content
                .animation(animation, value: trigger)
        }
    }
    
    struct ShakeEffect: GeometryEffect {
        var amount: CGFloat = 10
        var shakesPerUnit = 3
        var animatableData: CGFloat
        
        func effectValue(size: CGSize) -> ProjectionTransform {
            ProjectionTransform(CGAffineTransform(translationX:
                amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0))
        }
    }
}

extension View {
    func shake(_ trigger: Bool) -> some View {
        modifier(Animations.ShakeEffect(animatableData: trigger ? 1 : 0))
    }
    
    func withSpringAnimation(_ trigger: Binding<Bool>) -> some View {
        modifier(Animations.AnimationModifier(animation: .spring(), trigger: trigger))
    }
    
    func withCustomAnimation(_ animation: Animation, trigger: Binding<Bool>) -> some View {
        modifier(Animations.AnimationModifier(animation: animation, trigger: trigger))
    }
}
