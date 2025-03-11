//
//  HomeViewModel.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/28/24.
//

import SwiftUI
import Foundation
import Combine

class HomeViewModel: ObservableObject {
    // Published properties
    @Published var currentAI: AI?
    @Published var messages: [Message] = []
    @Published var isTyping = false
    @Published var availableAIs: [AI] = []
    @Published var searchText = ""
    
    // Services
    private let chatManager = ChatManager.shared
    private let aiManager = AIManager.shared
    private let locationService = LocationService()
    
    // Subscribers
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupSubscriptions()
        loadInitialData()
        
        // Start location monitoring
        locationService.startMonitoring()
    }
    
    // MARK: - Public Methods
    
    func handleAISelection(_ ai: AI) {
        currentAI = ai
        loadMessages(for: ai)
        aiManager.selectAI(ai)
        
        HapticManager.performAISelection()
    }
    
    func sendMessage(_ content: String, attachments: [Message.Attachment]? = nil) {
        guard !content.isEmpty else { return }
        
        isTyping = true
        chatManager.sendMessage(content, attachments: attachments)
        
        // Update UI state
        withAnimation {
            messages = chatManager.messages
        }
    }
    
    func filterMessages(searchText: String) {
        guard let ai = currentAI else { return }
        
        if searchText.isEmpty {
            loadMessages(for: ai)
        } else {
            messages = chatManager.messages.filter {
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    func processLocationContext(_ context: Message.LocationContext) {
        chatManager.sendLocationContext(context)
        messages = chatManager.messages
    }
    
    // MARK: - Private Methods
    
    private func setupSubscriptions() {
        // Listen for new messages
        chatManager.$messages
            .receive(on: DispatchQueue.main)
            .sink { [weak self] messages in
                self?.messages = messages
            }
            .store(in: &cancellables)
        
        // Listen for typing state
        chatManager.$isTyping
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isTyping in
                self?.isTyping = isTyping
            }
            .store(in: &cancellables)
        
        // Listen for location updates
        locationService.$locationContext
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] context in
                self?.handleLocationUpdate(context)
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() {
        availableAIs = aiManager.availableAIs
        
        // Load last used AI if available
        if let lastUsedAI = availableAIs.first {
            handleAISelection(lastUsedAI)
        }
    }
    
    private func loadMessages(for ai: AI) {
        chatManager.loadChat(for: ai.id)
        messages = chatManager.messages
    }
    
    private func handleLocationUpdate(_ context: Message.LocationContext) {
        guard let currentAI = currentAI else { return }
        
        // Check if AI should respond to location
        if currentAI.category == .friend || currentAI.category == .utility {
            processLocationContext(context)
        }
    }
}

// MARK: - Preview Helper
extension HomeViewModel {
    static var preview: HomeViewModel {
        let viewModel = HomeViewModel()
        // Add mock data for preview
        viewModel.messages = [
            Message(
                id: UUID(),
                content: "Hello! How can I help you today?",
                timestamp: Date(),
                type: .text,
                sender: .ai(UUID())
            ),
            Message(
                id: UUID(),
                content: "Hi! I have a question.",
                timestamp: Date(),
                type: .text,
                sender: .user
            )
        ]
        return viewModel
    }
}

