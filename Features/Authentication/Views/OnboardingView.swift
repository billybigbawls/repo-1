//
//  OnboardingView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isShowing: Bool
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Squad",
            subtitle: "Your AI companions, all in one place",
            icon: "sparkles",
            color: .blue
        ),
        OnboardingPage(
            title: "Create Squads",
            subtitle: "Combine AIs for unique experiences",
            icon: "person.3.fill",
            color: .purple
        ),
        OnboardingPage(
            title: "Smart Context",
            subtitle: "Location-aware conversations that adapt to you",
            icon: "location.fill",
            color: .orange
        ),
        OnboardingPage(
            title: "Secure & Private",
            subtitle: "End-to-end encryption for your peace of mind",
            icon: "lock.shield.fill",
            color: .green
        )
    ]
    
    var body: some View {
        ZStack {
            // Content
            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        OnboardingPageView(page: page)
                            .tag(pages.firstIndex(where: { $0.id == page.id }) ?? 0)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: UIScreen.main.bounds.height * 0.6)
                
                // Page control
                PageControl(numberOfPages: pages.count, currentPage: $currentPage)
                    .padding(.top, 20)
                
                Spacer()
                
                // Buttons
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            isShowing = false
                        }
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    Button("Skip Tour") {
                        withAnimation {
                            isShowing = false
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal)
        }
        .background(
            Color.white.opacity(0.2)
                .glassMorphic()
        )
        .cornerRadius(30)
        .padding()
    }
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: page.icon)
                    .font(.system(size: 40))
                    .foregroundColor(page.color)
            }
            .scaleEffect(isAnimating ? 1 : 0.5)
            .opacity(isAnimating ? 1 : 0)
            
            // Text
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .offset(y: isAnimating ? 0 : 20)
                    .opacity(isAnimating ? 1 : 0)
                
                Text(page.subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .offset(y: isAnimating ? 0 : 20)
                    .opacity(isAnimating ? 1 : 0)
            }
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

struct PageControl: View {
    let numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: page == currentPage ? 10 : 8,
                           height: page == currentPage ? 10 : 8)
                    .animation(.spring(), value: currentPage)
            }
        }
    }
}

#Preview {
    OnboardingView(isShowing: .constant(true))
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.lightBlue, Color.pastelTan, Color.pastelPink] as [Color]),
                startPoint: .trailing,
                endPoint: .leading
            )
        )
}
