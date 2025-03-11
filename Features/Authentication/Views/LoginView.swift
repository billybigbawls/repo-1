//
//  LoginView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthenticationViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isShowingEmailLogin = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Text("Welcome to Squad")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Chat with AI, your way")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 60)
            
            Spacer()
            
            // Main content
            if isShowingEmailLogin {
                emailLoginView
                    .transition(.move(edge: .trailing))
            } else {
                quickStartView
                    .transition(.move(edge: .leading))
            }
            
            Spacer()
            
            // Footer
            footerView
                .padding(.bottom, 30)
        }
        .padding()
        .background(
            Color.white.opacity(0.2)
                .glassMorphic()
        )
        .cornerRadius(30)
        .padding()
    }
    
    private var quickStartView: some View {
        VStack(spacing: 20) {
            // Quick start button
            AuthButton(
                title: "Quick Start",
                subtitle: "Use device ID only",
                icon: "bolt.fill"
            ) {
                withAnimation {
                    SystemSound.playForAISelection()
                    viewModel.authenticateWithDevice()
                }
            }
            
            // Email login option
            AuthButton(
                title: "Sign in with Email",
                subtitle: "Sync across devices",
                icon: "envelope.fill",
                style: .secondary    
            ) {
                withAnimation {
                    isShowingEmailLogin = true
                }
            }
        }
    }
    
    
    private var emailLoginView: some View {
        VStack(spacing: 20) {
            // Email field
            AuthTextField(
                text: $email,
                placeholder: "Email",
                icon: "envelope.fill",
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            
            // Password field
            AuthTextField(
                text: $password,
                placeholder: "Password",
                icon: "lock.fill",
                isSecure: true
            )
            
            if let error = viewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            // Login button
            AuthButton(
                title: "Sign In",
                icon: "arrow.right.circle.fill",
                isLoading: viewModel.isLoading
            ) {
                SystemSound.playForAISelection()
                viewModel.authenticateWithEmail(email, password: password)
            }
            .disabled(email.isEmpty || password.isEmpty || viewModel.isLoading)
            
            // Back button
            Button("Back to Quick Start") {
                withAnimation {
                    isShowingEmailLogin = false
                }
            }
            .font(.callout)
            .foregroundColor(.secondary)
        }
    }
    
    private var footerView: some View {
        VStack(spacing: 8) {
            Text("By continuing, you agree to our")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Button("Terms of Service") {
                    // Show terms
                }
                
                Text("and")
                    .foregroundColor(.secondary)
                
                Button("Privacy Policy") {
                    // Show privacy policy
                }
            }
            .font(.caption)
        }
    }
}

#Preview {
    LoginView(viewModel: AuthenticationViewModel())
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
}
