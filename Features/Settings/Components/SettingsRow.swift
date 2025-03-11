//
//  SettingsRow.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct SettingsRow: View {
    let title: String
    let icon: String
    var subtitle: String? = nil
    var showDivider: Bool = true
    var iconColor: Color = .blue
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: { action?() }) {
                HStack(spacing: 16) {
                    // Icon
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                        .frame(width: 24, height: 24)
                    
                    // Title and subtitle
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .foregroundColor(.primary)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Chevron if there's an action
                    if action != nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
            
            if showDivider {
                Divider()
                    .padding(.leading, 40)
            }
        }
    }
}

// Variants of SettingsRow for different use cases
extension SettingsRow {
    // Navigation row with default chevron
    static func navigation(
        title: String,
        icon: String,
        subtitle: String? = nil,
        iconColor: Color = .blue
    ) -> SettingsRow {
        SettingsRow(
            title: title,
            icon: icon,
            subtitle: subtitle,
            iconColor: iconColor,
            action: {}
        )
    }
    
    // Action row without chevron
    static func action(
        title: String,
        icon: String,
        iconColor: Color = .blue,
        action: @escaping () -> Void
    ) -> SettingsRow {
        SettingsRow(
            title: title,
            icon: icon,
            iconColor: iconColor,
            action: action
        )
    }
    
    // Info row without any interaction
    static func info(
        title: String,
        icon: String,
        subtitle: String? = nil,
        iconColor: Color = .blue
    ) -> SettingsRow {
        SettingsRow(
            title: title,
            icon: icon,
            subtitle: subtitle,
            iconColor: iconColor
        )
    }
}

// Preview
struct SettingsRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            // Navigation style
            SettingsRow.navigation(
                title: "Account",
                icon: "person.circle",
                subtitle: "Manage your account settings"
            )
            
            // Action style
            SettingsRow.action(
                title: "Log Out",
                icon: "arrow.right.square",
                iconColor: .red
            ) {
                print("Log out tapped")
            }
            
            // Info style
            SettingsRow.info(
                title: "Version",
                icon: "info.circle",
                subtitle: "1.0.0"
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .previewLayout(.sizeThatFits)
    }
}
