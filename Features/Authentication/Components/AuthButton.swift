//
//  AuthButton1.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct AuthButton: View {
    let title: String
    var subtitle: String? = nil
    let icon: String
    var style: AuthButtonStyle = .primary
    var isLoading: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if !isLoading {
                HapticManager.selection()
                action()
            }
        }) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    if isLoading {
                        ProgressView(topAIs: []) //double check if follows logic
                            .progressViewStyle(CircularProgressViewStyle(tint: style.iconColor))
                    } else {
                        Image(systemName: icon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(style.iconColor)
                    }
                }
                .frame(width: 24, height: 24)
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(style.textColor)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(style.subtitleColor)
                    }
                }
                
                Spacer()
                
                // Arrow
                if style == .primary {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(style.iconColor)
                        .opacity(isLoading ? 0 : 1)
                }
            }
            .padding()
            .background(style.backgroundColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
            .shadow(
                color: style.shadowColor,
                radius: style.shadowRadius,
                x: 0,
                y: style.shadowRadius / 2
            )
        }
        .disabled(isLoading)
    }
}

enum AuthButtonStyle {
    case primary
    case secondary
    
    var backgroundColor: Color {
        switch self {
        case .primary:
            return .blue
        case .secondary:
            return .white.opacity(0.9)
        }
    }
    
    var textColor: Color {
        switch self {
        case .primary:
            return .white
        case .secondary:
            return .primary
        }
    }
    
    var subtitleColor: Color {
        switch self {
        case .primary:
            return .white.opacity(0.8)
        case .secondary:
            return .secondary
        }
    }
    
    var iconColor: Color {
        switch self {
        case .primary:
            return .white
        case .secondary:
            return .blue
        }
    }
    
    var borderColor: Color {
        switch self {
        case .primary:
            return .clear
        case .secondary:
            return .gray.opacity(0.2)
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .primary:
            return 0
        case .secondary:
            return 1
        }
    }
    
    var shadowColor: Color {
        switch self {
        case .primary:
            return .black.opacity(0.2)
        case .secondary:
            return .black.opacity(0.1)
        }
    }
    
    var shadowRadius: CGFloat {
        switch self {
        case .primary:
            return 8
        case .secondary:
            return 4
        }
    }
}

// Preview
struct AuthButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Primary button
            AuthButton(
                title: "Quick Start",
                subtitle: "Use device ID only",
                icon: "bolt.fill",
                style: .primary
            ) {}
            
            // Secondary button
            AuthButton(
                title: "Sign in with Email",
                subtitle: "Sync across devices",
                icon: "envelope.fill",
                style: .secondary
            ) {}
            
            // Loading state
            AuthButton(
                title: "Loading",
                icon: "arrow.right.circle.fill",
                isLoading: true
            ) {}
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
}
