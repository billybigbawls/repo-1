//
//  ChatBackgroundView.swift
//  Squad
//
//  Created for Squad App
//

import SwiftUI
import AVKit

enum BackgroundCategory: String {
    case irl
    case color
    case animated
    case video
}

struct ChatBackgroundSettings {
    var category: BackgroundCategory = .color
    var colorType: ColorType = .solid
    var animationType: AnimationType = .bubbles
    var videoId: String?
    var primaryColor: Color = .appBackground
    var secondaryColor: Color? = nil
    var isWeatherEnabled: Bool = true
    var isLocationBasedWeather: Bool = false
    var weatherCondition: WeatherState.WeatherCondition = .clear
    
    enum ColorType: Int {
        case solid
        case gradient
    }
    
    enum AnimationType: Int {
        case bubbles
        case dots
        case waves
    }
}

struct ChatBackgroundView: View {
    let settings: ChatBackgroundSettings
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var weatherState = WeatherState()
    @State private var player: AVPlayer?
    
    // For backwards compatibility
    init(type: String) {
        // Convert string type to ChatBackgroundSettings
        var defaultSettings = ChatBackgroundSettings()
        
        switch type {
        case "bubbles":
            defaultSettings.category = .animated
            defaultSettings.animationType = .bubbles
        case "dots":
            defaultSettings.category = .animated
            defaultSettings.animationType = .dots
        case "waves":
            defaultSettings.category = .animated
            defaultSettings.animationType = .waves
        default:
            // Use default settings
            defaultSettings.category = .color
            defaultSettings.colorType = .solid
        }
        
        self.settings = defaultSettings
    }
    
    // New initializer for full settings
    init(settings: ChatBackgroundSettings) {
        self.settings = settings
        
        // Initialize video player if needed
        if settings.category == .video, let videoId = settings.videoId {
            let videoURL = URL(string: "https://yourbackend.com/api/backgrounds/videos/\(videoId)")!
            _player = State(initialValue: AVPlayer(url: videoURL))
        }
    }
    
    var body: some View {
        ZStack {
            // Base background
            backgroundLayer
            
            // Weather effects if enabled in IRL mode
            if settings.category == .irl && settings.isWeatherEnabled {
                WeatherEffectView(condition: settings.isLocationBasedWeather ?
                                 weatherState.currentCondition : settings.weatherCondition)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            if settings.category == .irl && settings.isLocationBasedWeather {
                // Set up location-based weather
                weatherState.setupLocationBasedWeather()
            }
            
            // Start video playback if using video background
            player?.play()
        }
        .onDisappear {
            player?.pause()
        }
    }
    
    @ViewBuilder
    private var backgroundLayer: some View {
        switch settings.category {
        case .irl:
            // Base gradient for weather
            LinearGradient(
                gradient: Gradient(colors: weatherGradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.8)
            
        case .color:
            if settings.colorType == .gradient {
                LinearGradient(
                    gradient: Gradient(colors: [
                        settings.primaryColor,
                        settings.secondaryColor ?? settings.primaryColor.opacity(0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                settings.primaryColor
            }
            
        case .animated:
            ZStack {
                // Base color/gradient
                if settings.colorType == .gradient {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            settings.primaryColor,
                            settings.secondaryColor ?? settings.primaryColor.opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    settings.primaryColor
                }
                
                // Animation layer
                animationLayer
            }
            
        case .video:
            if let player = player {
                VideoPlayerBackground(player: player)
                    .overlay(
                        settings.primaryColor.opacity(0.2)
                    )
            } else {
                // Fallback if video can't be loaded
                settings.primaryColor
            }
        }
    }
    
    @ViewBuilder
    private var animationLayer: some View {
        switch settings.animationType {
        case .bubbles:
            BubblesBackground()
        case .dots:
            DotsBackground()
        case .waves:
            WavesBackground()
        }
    }
    
    private var weatherGradientColors: [Color] {
        switch weatherState.currentCondition {
        case .clear:
            return colorScheme == .dark
                ? [Color.darkBlue, Color.black.opacity(0.7)]
                : [Color.lightBlue, Color.white.opacity(0.7)]
        case .rain:
            return colorScheme == .dark
                ? [Color.darkBlue, Color.navy]
                : [Color.gray.opacity(0.7), Color.lightBlue.opacity(0.8)]
        case .snow:
            return colorScheme == .dark
                ? [Color.darkBlue, Color.navy.opacity(0.8)]
                : [Color.white.opacity(0.9), Color.lightBlue.opacity(0.4)]
        case .cloudy:
            return colorScheme == .dark
                ? [Color.darkBlue, Color.gray.opacity(0.8)]
                : [Color.lightBlue.opacity(0.6), Color.gray.opacity(0.4)]
        }
    }
}

// Weather-related views and effects
class WeatherState: ObservableObject {
    @Published var isWeatherEnabled = true
    @Published var currentCondition: WeatherCondition = .clear
    
    enum WeatherCondition: String, CaseIterable {
        case clear
        case rain
        case snow
        case cloudy
    }
    
    func setupLocationBasedWeather() {
        // In a real implementation, this would use LocationService to get current weather
        // For now, we'll use a placeholder implementation
        LocationService.shared.getCurrentWeather { [weak self] condition in
            DispatchQueue.main.async {
                self?.currentCondition = condition ?? .clear
            }
        }
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
    @State private var phase = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<20, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 20...60))
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 4...7))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: phase
                        )
                }
            }
            .onAppear {
                phase = 1.0
            }
        }
    }
}

struct DotsBackground: View {
    @State private var phase = 0.0
    
    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                for i in 0..<100 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let path = Path(ellipseIn: CGRect(x: x, y: y, width: 2, height: 2))
                    context.fill(path, with: .color(.white.opacity(0.1 + sin(phase + Double(i)) * 0.05)))
                }
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                phase = .pi * 2
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
    @State private var sunPosition = 0.0
    
    var body: some View {
        ZStack {
            // Sun rays
            ForEach(0..<8, id: \.self) { i in
                Rectangle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 3, height: 30)
                    .offset(y: -50)
                    .rotationEffect(.degrees(Double(i) * 45 + sunPosition))
            }
            
            // Sun
            Circle()
                .fill(Color.yellow.opacity(0.3))
                .frame(width: 50, height: 50)
            
            // Light flare
            Circle()
                .fill(Color.yellow.opacity(0.1))
                .frame(width: 80, height: 80)
                .blur(radius: 10)
        }
        .position(x: UIScreen.main.bounds.width * 0.8, y: UIScreen.main.bounds.height * 0.2)
        .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                sunPosition = 360
            }
        }
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
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Cloud(size: CGFloat.random(in: 100...200), opacity: 0.2)
                    .position(
                        x: CGFloat.random(in: -50...UIScreen.main.bounds.width + 50) + offset * (i % 2 == 0 ? 1 : -1),
                        y: CGFloat.random(in: -50...UIScreen.main.bounds.height / 2)
                    )
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 30).repeatForever(autoreverses: true)) {
                offset = 50
            }
        }
    }
}

struct Cloud: View {
    let size: CGFloat
    let opacity: Double
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: size * 0.5, height: size * 0.5)
                .offset(x: -size * 0.2)
            
            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: size * 0.7, height: size * 0.7)
            
            Circle()
                .fill(Color.white.opacity(opacity))
                .frame(width: size * 0.5, height: size * 0.5)
                .offset(x: size * 0.2)
        }
        .frame(width: size, height: size)
        .blur(radius: 10)
    }
}

struct VideoPlayerBackground: View {
    let player: AVPlayer
    
    var body: some View {
        VideoPlayer(player: player)
            .disabled(true)
            .aspectRatio(contentMode: .fill)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                // Loop video
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player.currentItem,
                    queue: .main) { _ in
                        player.seek(to: .zero)
                        player.play()
                    }
            }
    }
}

// Helper color extensions
extension Color {
    static let darkBlue = Color(red: 0.1, green: 0.1, blue: 0.3)
    static let lightBlue = Color(red: 0.6, green: 0.8, blue: 1.0)
    static let navy = Color(red: 0.0, green: 0.0, blue: 0.5)
}
