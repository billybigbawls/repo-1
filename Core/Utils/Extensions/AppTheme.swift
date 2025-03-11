//
//  AppTheme.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 12/26/24.
//

import SwiftUI

struct ThemeColor {
    static let lightBlue = Color("lightBlue")
    static let pastelTan = Color("pastelTan")
    static let pastelPink = Color("pastelPink")
    static let backgroundPrimary = Color("backgroundPrimary")
    static let backgroundSecondary = Color("backgroundSecondary")
    static let textPrimary = Color("textPrimary")
    static let black = Color.black
    
    static let darkBlue = Color("darkBlue")
    static let darkTan = Color("darkTan")
    static let darkPink = Color("darkPink")
}

struct AppTheme {
    let primary: Color
    let secondary: Color
    let tertiary: Color
    let background: Color
    let surface: Color
    let text: Color
    let shadow: Color
    
    static let defaultTheme: AppTheme = AppTheme(
        primary: ThemeColor.lightBlue,
        secondary: ThemeColor.pastelTan,
        tertiary: ThemeColor.pastelPink,
        background: ThemeColor.backgroundPrimary,
        surface: ThemeColor.backgroundSecondary,
        text: ThemeColor.textPrimary,
        shadow: ThemeColor.black.opacity(0.1)
    )
    
    static let darkTheme: AppTheme = AppTheme(
        primary: ThemeColor.darkBlue,
        secondary: ThemeColor.darkTan,
        tertiary: ThemeColor.darkPink,
        background: ThemeColor.backgroundPrimary,
        surface: ThemeColor.backgroundSecondary,
        text: ThemeColor.textPrimary,
        shadow: ThemeColor.black.opacity(0.2)
    )
}
