//
//  ChatBackgroundView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct ChatBackgroundView: View {
    let type: String
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var weatherState = WeatherState()
    
    var body: some View {
        ZStack {
            // Base gradient background
            backgroundGradient
            
            // Weather effects if enabled
            if weatherState.isWeatherEnabled {
                WeatherEffectView(condition: weatherState.currentCondition)
            }
            
            // Custom background pattern or image based on type
            customBackground
        }
        .ignoresSafeArea()
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: backgroundColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.8)
    }
    
    private var backgroundColors: [Color] {
        switch type {
        case "default":
            return colorScheme == .dark
                ? [.darkBlue, .black.opacity(0.6)]
                : [.lightBlue, .white.opacity(0.6)]
        // Add more custom background types here
        default:
            return colorScheme == .dark
                ? [.darkBlue, .black.opacity(0.6)]
                : [.lightBlue, .white.opacity(0.6)]
        }
    }
    
    @ViewBuilder
    private var customBackground: some View {
        switch type {
        case "bubbles":
            BubblesBackground()
        case "dots":
            DotsBackground()
        case "waves":
            WavesBackground()
        default:
            EmptyView()
        }
    }
}

// Weather-related views and effects
class WeatherState: ObservableObject {
    @Published var isWeatherEnabled = true
    @Published var currentCondition: WeatherCondition = .clear
    
    enum WeatherCondition {
        case clear
        case rain
        case snow
        case cloudy
    }
}

struct WeatherEffectView: View {
    let condition: WeatherState.WeatherCondition
    
    var body: some View {
        ZStack {
            switch condition {
            case .clear:
                ClearWeatherEffect()
            case .rain:
                RainEffect()
            case .snow:
                SnowEffect()
            case .cloudy:
                CloudyEffect()
            }
        }
    }
}

// Background pattern views
struct BubblesBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<20) { _ in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: CGFloat.random(in: 20...60))
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height)
                    )
            }
        }
    }
}

struct DotsBackground: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<100 {
                let x = Double.random(in: 0...size.width)
                let y = Double.random(in: 0...size.height)
                let path = Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2))
                context.fill(path, with: .color(.white.opacity(0.1)))
            }
        }
    }
}

struct WavesBackground: View {
    @State private var phase = 0.0
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let timeNow = timeline.date.timeIntervalSinceReferenceDate
                let angle = timeNow.remainder(dividingBy: 2)
                let magnitude = (size.width * 0.04)
                
                context.translateBy(x: size.width * 0.5, y: size.height * 0.5)
                context.rotate(by: .degrees(angle * 30))
                
                let colors = [
                    Color.white.opacity(0.1),
                    Color.white.opacity(0.2),
                    Color.white.opacity(0.1)
                ]
                
                for i in 0..<3 {
                    let path = createWavePath(
                        size: size,
                        magnitude: magnitude,
                        frequency: Double(i + 1) * 2,
                        phase: phase + Double(i) * .pi / 3
                    )
                    context.stroke(
                        path,
                        with: .color(colors[i]),
                        lineWidth: 2
                    )
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }
    
    private func createWavePath(size: CGSize, magnitude: Double, frequency: Double, phase: Double) -> Path {
        var path = Path()
        let steps = Int(size.width)
        
        for step in 0...steps {
            let x = Double(step) * size.width / Double(steps) - size.width / 2
            let y = sin(x / size.width * frequency * .pi + phase) * magnitude
            
            if step == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

// Weather effect implementations
struct ClearWeatherEffect: View {
    var body: some View {
        EmptyView() // Clear weather doesn't need special effects
    }
}

struct RainEffect: View {
    let numberOfDrops = 100
    
    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                for _ in 0..<numberOfDrops {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let path = Path(roundedRect: CGRect(x: x, y: y, width: 1, height: 10),
                                  cornerRadius: 0.5)
                    context.fill(path, with: .color(.white.opacity(0.3)))
                }
            }
        }
    }
}

struct SnowEffect: View {
    let numberOfFlakes = 50
    
    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                for _ in 0..<numberOfFlakes {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let flakeSize = Double.random(in: 2...4)
                    let path = Path(ellipseIn: CGRect(x: x, y: y,
                                                     width: flakeSize,
                                                     height: flakeSize))
                    context.fill(path, with: .color(.white.opacity(0.4)))
                }
            }
        }
    }
}

struct CloudyEffect: View {
    var body: some View {
        ZStack {
            ForEach(0..<5) { _ in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: CGFloat.random(in: 100...200))
                    .position(
                        x: CGFloat.random(in: -50...UIScreen.main.bounds.width + 50),
                        y: CGFloat.random(in: -50...UIScreen.main.bounds.height + 50)
                    )
                    .blur(radius: 20)
            }
        }
    }
}

#Preview {
    ChatBackgroundView(type: "default")
}
