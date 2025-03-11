//
//  View+Extensions.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI
import Foundation


extension View {
    func glassMorphic() -> some View {
        self.background(
            Color.white
                .opacity(Constants.Glass.opacity)
                .blur(radius: Constants.Glass.blur)
        )
        .background(
            Color.white.opacity(0.05)
        )
    }
    
    func softShadow() -> some View {
        self.shadow(
            color: Constants.ShadowStyle.medium.color,
            radius: Constants.ShadowStyle.medium.radius,
            x: Constants.ShadowStyle.medium.x,
            y: Constants.ShadowStyle.medium.y
        )
    }
}

extension View {
    func preview(title: String = "Preview") -> some View {
        self
            .previewLayout(.sizeThatFits)
            .previewDisplayName(title)
            .padding()
            .background(Color(.systemBackground))
    }
}

struct ThemePreviewButton: View {
    let theme: Theme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Circle()
                    .fill(themeColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.blue, lineWidth: isSelected ? 2 : 0)
                    )
                Text(theme.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
        }
    }

    private var themeColor: Color {
        switch theme {
        case .classic: return .blue
        case .dark: return .gray
        case .light: return .white
        case .nature: return .green
        case .ocean: return .cyan
        }
    }
}
