//
//  ShopkeeperView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI
import Lottie

struct ShopkeeperView: View {
    let animation: String
    @State private var isWaving = false
    
    var body: some View {
        ZStack {
            // Background elements
            Circle()
                .fill(Color.white.opacity(0.1))
                .scaleEffect(1.5)
            
            // Shopkeeper container
            LottieViewContainer(animationName: animation)
                .modifier(WaveModifier(isWaving: isWaving))
            
            // Greeting bubble
            if isWaving {
                GreetingBubble()
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(
                Animation
                    .easeInOut(duration: 2.25)
                    .repeatForever(autoreverses: true)
            ) {
                isWaving = true
            }
        }
    }
}

// Lottie animation container
struct LottieViewContainer: UIViewRepresentable {
    let animationName: String
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
        
        // Setup constraints
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if needed
    }
}

struct WaveModifier: AnimatableModifier {
    var isWaving: Bool
    
    var animatableData: CGFloat {
        get { isWaving ? 1 : 0 }
        set { isWaving = newValue > 0.5 }
    }
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(isWaving ? 5 : -5),
                axis: (x: 0, y: 0, z: 1)
            )
    }
}

struct GreetingBubble: View {
    @State private var currentGreeting = 0
    let greetings = [
        "Welcome to the Shop!",
        "All AI's are free!",
        "Add them to your chat, now!"
    ]
    
    var body: some View {
        Text(greetings[currentGreeting])
            .font(.system(.headline, design: .rounded))
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.9))
            )
            .overlay(
                Triangle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 20, height: 10)
                    .offset(x: 0, y: -1),
                alignment: .bottom
            )
            .offset(y: -60)
            .onAppear {
                startGreetingCycle()
            }
    }
    
    private func startGreetingCycle() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            withAnimation {
                currentGreeting = (currentGreeting + 1) % greetings.count
            }
        }
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// Preview
struct ShopkeeperView_Previews: PreviewProvider {
    static var previews: some View {
        ShopkeeperView(animation: "shopkeeper_wave")
            .frame(height: 200)
            .padding()
            .background(Color.gray.opacity(0.2))
            .previewLayout(.sizeThatFits)
    }
}
