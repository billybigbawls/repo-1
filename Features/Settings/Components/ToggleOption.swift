//
//  ToggleOption.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct ToggleOption: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    var subtitle: String? = nil
    var iconColor: Color = .blue
    
    var body: some View {
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
            
            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .onChange(of: isOn) { newValue in
                    HapticManager.selection()
                }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
    }
}

// Variants for different use cases
extension ToggleOption {
    // Simple toggle without subtitle
    static func simple(
        title: String,
        icon: String,
        isOn: Binding<Bool>
    ) -> ToggleOption {
        ToggleOption(
            title: title,
            icon: icon,
            isOn: isOn
        )
    }
    
    // Detailed toggle with subtitle
    static func detailed(
        title: String,
        icon: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> ToggleOption {
        ToggleOption(
            title: title,
            icon: icon,
            isOn: isOn,
            subtitle: subtitle
        )
    }
    
    // Warning toggle with red icon
    static func warning(
        title: String,
        icon: String,
        isOn: Binding<Bool>
    ) -> ToggleOption {
        ToggleOption(
            title: title,
            icon: icon,
            isOn: isOn,
            iconColor: .red
        )
    }
}

// Preview
struct ToggleOption_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Simple toggle
            ToggleOption.simple(
                title: "Notifications",
                icon: "bell.fill",
                isOn: .constant(true)
            )
            
            // Detailed toggle
            ToggleOption.detailed(
                title: "Location Services",
                icon: "location.fill",
                subtitle: "Allow app to access your location",
                isOn: .constant(false)
            )
            
            // Warning toggle
            ToggleOption.warning(
                title: "Delete Account",
                icon: "trash.fill",
                isOn: .constant(false)
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .previewLayout(.sizeThatFits)
    }
}

// Helper view for toggle animations
struct ToggleBackground: View {
    @Binding var isOn: Bool
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(isOn ? Color.green : Color.gray)
            .frame(width: 51, height: 31)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .shadow(radius: 1)
                    .frame(width: 27, height: 27)
                    .offset(x: isOn ? 10 : -10)
            )
    }
}
