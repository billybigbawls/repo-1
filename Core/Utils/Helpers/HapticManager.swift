//
//  HapticManager.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import UIKit

enum HapticManager {
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    static func lightImpact() {
        impact(style: .light)
    }
    
    static func mediumImpact() {
        impact(style: .medium)
    }
    
    static func heavyImpact() {
        impact(style: .heavy)
    }
    
    static func success() {
        notification(type: .success)
    }
    
    static func warning() {
        notification(type: .warning)
    }
    
    static func error() {
        notification(type: .error)
    }
}

// Usage Examples
extension HapticManager {
    static func performAISelection() {
        lightImpact()
    }
    
    static func performSquadFormation() {
        success()
    }
    
    static func performMessageSent() {
        mediumImpact()
    }
    
    static func performError() {
        error()
    }
}
