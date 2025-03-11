//
//  AuthTextField.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    
    @State private var isEditing = false
    @State private var showPassword = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isEditing ? .blue : .gray)
                    .frame(width: 24)
                
                // Text field
                Group {
                    if isSecure && !showPassword {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .textInputAutocapitalization(autocapitalization)
                .keyboardType(keyboardType)
                .onChange(of: text) { _ in
                    HapticManager.selection()
                }
                
                // Show/hide password button
                if isSecure {
                    Button(action: {
                        withAnimation {
                            showPassword.toggle()
                        }
                        HapticManager.selection()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isEditing ? Color.blue : Color.gray.opacity(0.2), lineWidth: 1)
            )
            .onTapGesture {
                withAnimation {
                    isEditing = true
                }
            }
            
            // Error message (if needed)
            if let errorMessage = validateInput() {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
        }
        .onAppear {
            // Reset secure text entry when view appears
            showPassword = false
        }
    }
    
    private func validateInput() -> String? {
        // Add validation logic here
        if keyboardType == .emailAddress && !text.isEmpty {
            if !isValidEmail(text) {
                return "Please enter a valid email address"
            }
        }
        
        if isSecure && !text.isEmpty && text.count < 6 {
            return "Password must be at least 6 characters"
        }
        
        return nil
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}

// Custom modifiers for text field styling
extension AuthTextField {
    func withFloatingLabel() -> some View {
        self.modifier(FloatingLabelModifier(placeholder: placeholder, text: text))
    }
}

struct FloatingLabelModifier: ViewModifier {
    let placeholder: String
    let text: String
    
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            Text(placeholder)
                .font(.caption)
                .foregroundColor(.secondary)
                .offset(y: text.isEmpty ? 0 : -25)
                .scaleEffect(text.isEmpty ? 1 : 0.8, anchor: .leading)
            
            content
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: text)
    }
}

// Preview
struct AuthTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Regular text field
            AuthTextField(
                text: .constant(""),
                placeholder: "Name",
                icon: "person.fill"
            )
            
            // Email field
            AuthTextField(
                text: .constant("user@example.com"),
                placeholder: "Email",
                icon: "envelope.fill",
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            
            // Password field
            AuthTextField(
                text: .constant("password"),
                placeholder: "Password",
                icon: "lock.fill",
                isSecure: true
            )
            
            // Error state
            AuthTextField(
                text: .constant("invalid@email"),
                placeholder: "Email",
                icon: "envelope.fill",
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
}
