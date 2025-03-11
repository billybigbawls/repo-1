//
//  SoundManager.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 11/2/24.
//

import SwiftUI
import UIKit
import AudioToolbox
import AVFoundation

enum SystemSound: String {
    // Navigation & Selection
    case aiSelected = "1519"        // Tap selection
    case wheelScroll = "1100"       // Mechanical click
    case tap = "1104"              // Lighter click
    
    // Messages
    case messageReceived = "1003"   // Sent message tone
    case messageSent = "1004"       // Received message tone
    
    // Status
    case success = "1325"          // Positive completion
    case error = "1107"            // Error beep
    case unlock = "1101"           // Unlock sound
    case squadCreated = "1323"     // Triumph sound
    
    var id: SystemSoundID {
        return SystemSoundID(rawValue) ?? 1000
    }
}

class SoundManager {
    static let shared = SoundManager()
    private var isEnabled = true
    
    private init() {
        setupAudioSession()
    }
    
    // MARK: - Public Methods
    
    func play(_ sound: SystemSound) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSound(sound.id)
    }
    
    func playHaptic(_ sound: SystemSound) {
        guard isEnabled else { return }
        AudioServicesPlaySystemSoundWithCompletion(sound.id) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    func toggleSound(enabled: Bool) {
        isEnabled = enabled
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .ambient,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
}

// MARK: - Convenience Extensions
extension SystemSound {
    static func playForAIWheel() {
        // Softer sound for continuous scrolling
        SoundManager.shared.play(.wheelScroll)
    }
    
    static func playForAISelection() {
        // More prominent sound with haptic
        SoundManager.shared.playHaptic(.aiSelected)
    }
    
    static func playForMessage(sent: Bool) {
        SoundManager.shared.play(sent ? .messageSent : .messageReceived)
    }
    
    static func playForSquadCreation() {
        SoundManager.shared.playHaptic(.squadCreated)
    }
}

// MARK: - View Extension for Easy Usage
extension View {
    func withSystemSound(_ sound: SystemSound, haptic: Bool = false) -> some View {
        self.onTapGesture {
            if haptic {
                SoundManager.shared.playHaptic(sound)
            } else {
                SoundManager.shared.play(sound)
            }
        }
    }
}

