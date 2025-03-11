//
//  Color+Extensions.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

extension Color {
    static func dynamic(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return UIColor(light)
            case .dark:
                return UIColor(dark)
            case .unspecified:
                return UIColor(light)
            @unknown default:
                return UIColor(light)
            }
        })
    }
}
