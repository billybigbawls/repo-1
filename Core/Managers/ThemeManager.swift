//
//  ThemeManager.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 12/26/24.
//

import SwiftUI

class ThemeManager: ObservableObject {
    @Published var colorScheme: ColorScheme = .light
    @Published var currentTheme: AppTheme = AppTheme.defaultTheme

    func toggleColorScheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            colorScheme = (colorScheme == .light) ? .dark : .light
            currentTheme = (colorScheme == .light) ? AppTheme.defaultTheme : AppTheme.darkTheme
        }
    }
}
