//
//  AuthenticationView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var showOnboarding = true
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.lightBlue, .pastelTan, .pastelPink]),
                startPoint: .trailing,
                endPoint: .leading
            )
            .ignoresSafeArea()
            
            if showOnboarding {
                OnboardingView(isShowing: $showOnboarding)
                    .transition(.opacity.combined(with: .move(edge: .leading)))
            } else {
                LoginView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .animation(.spring(), value: showOnboarding)
    }
}

class AuthenticationViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    // Device ID for automatic authentication
    let deviceID = UUID().uuidString
    
    // Check if device has existing session
    func checkExistingSession() {
        // In real app, check stored credentials/token
        // For now, just check if device ID is stored
        if UserDefaults.standard.string(forKey: "deviceID") != nil {
            self.isAuthenticated = true
        }
    }
    
    // Authenticate with device ID only
    func authenticateWithDevice() {
        isLoading = true
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            UserDefaults.standard.set(self.deviceID, forKey: "deviceID")
            self.isAuthenticated = true
            self.isLoading = false
        }
    }
    
    // Optional email authentication
    func authenticateWithEmail(_ email: String, password: String) {
        isLoading = true
        error = nil
        
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Add validation logic here
            if email.contains("@") && password.count >= 6 {
                UserDefaults.standard.set(self.deviceID, forKey: "deviceID")
                UserDefaults.standard.set(email, forKey: "userEmail")
                self.isAuthenticated = true
            } else {
                self.error = "Invalid email or password"
            }
            self.isLoading = false
        }
    }
}

#Preview {
    AuthenticationView()
}
