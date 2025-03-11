//
//  Constants.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

enum Constants {
    static let cornerRadius: CGFloat = 12
    static let padding: CGFloat = 16
    static let defaultAnimation: Animation = .spring(response: 0.4, dampingFraction: 0.8)

    enum Haptics {
        static let selection = UIImpactFeedbackGenerator(style: .light)
        static let heavy = UIImpactFeedbackGenerator(style: .medium)
    }
    
    enum Font {
        static let title = SwiftUI.Font.system(.title, design: .rounded)
        static let headline = SwiftUI.Font.system(.headline, design: .rounded)
        static let body = SwiftUI.Font.system(.body, design: .rounded)
        static let caption = SwiftUI.Font.system(.caption, design: .rounded)
    }
    
    enum ShadowStyle {
        static let small = (color: Color.black.opacity(0.1), radius: 4.0, x: 0.0, y: 2.0)
        static let medium = (color: Color.black.opacity(0.15), radius: 8.0, x: 0.0, y: 4.0)
        static let large = (color: Color.black.opacity(0.2), radius: 16.0, x: 0.0, y: 8.0)
    }

    
    enum Glass {
        static let opacity: CGFloat = 0.7
        static let blur: CGFloat = 10
    }
    
    enum Layout {
        static let maxWidth: CGFloat = 414 // iPhone 12 Pro Max width
        static let maxHeight: CGFloat = 896 // iPhone 12 Pro Max height
        static let screenPadding: CGFloat = 16
        static let contentSpacing: CGFloat = 20
        static let avatarSize: CGFloat = 40
    }
    
    enum DefaultAnimation {
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.3)
        static let easeOut = SwiftUI.Animation.easeOut(duration: 0.3)
        static let easeIn = SwiftUI.Animation.easeIn(duration: 0.3)
    }
    
    enum Timing {
        static let defaultAnimationDuration: Double = 0.3
        static let longAnimationDuration: Double = 0.5
        static let quickAnimationDuration: Double = 0.15
    }
}
