//
//  ChatManager.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import Foundation
import Combine

class ChatManager: ObservableObject {
    static let shared = ChatManager()
    
    @Published private(set) var messages: [Message] = []
    @Published var isTyping = false
    
    private let storageService = StorageService()
    private let encryptionService = EncryptionService()
    private var cancellables = Set<AnyCancellable>()
    
    // Keep track of active chat context
    private var currentAIId: UUID?
    private var currentSquadId: UUID?
    
    init() {
        setupSubscriptions()
    }
    
    // MARK: - Public Methods
    
    func loadChat(for aiID: UUID) {
        currentAIId = aiID
        currentSquadId = nil

        guard let key = StorageService.StorageKey.messages(forAI: aiID) else {
            print("Error: Failed to generate StorageKey for AI Chat")
            messages = []
            return
        }

        if let savedMessages: [Message] = storageService.load([Message].self, forKey: key) {
            messages = savedMessages.sorted(by: { $0.timestamp < $1.timestamp })
        } else {
            messages = []
        }
    }

    func loadSquadChat(for squadID: UUID) {
        currentSquadId = squadID
        currentAIId = nil

        guard let key = StorageService.StorageKey.messages(forSquad: squadID) else {
            print("Error: Failed to generate StorageKey for Squad Chat")
            messages = []
            return
        }

        if let savedMessages: [Message] = storageService.load([Message].self, forKey: key) {
            messages = savedMessages.sorted(by: { $0.timestamp < $1.timestamp })
        } else {
            messages = []
        }
    }

    
    func sendMessage(_ content: String, attachments: [Message.Attachment]? = nil) {
        let message = Message(
            id: UUID(),
            content: content,
            timestamp: Date(),
            type: .text,
            sender: .user,
            attachments: attachments
        )
        
        addMessage(message)
        simulateAIResponse()
    }
    
    func sendLocationContext(_ context: Message.LocationContext) {
        let message = Message(
            id: UUID(),
            content: "Location shared",
            timestamp: Date(),
            type: .location,
            sender: .user,
            locationContext: context
        )
        
        addMessage(message)
        simulateAIResponse(forLocation: true)
    }
    
    func clearChat() {
        messages.removeAll()
        saveMessages()
    }
    
    // MARK: - Private Methods
    
    private func addMessage(_ message: Message) {
        messages.append(message)
        saveMessages()
        
        // Update AI stats if it's a user message
        if case .user = message.sender, let aiID = currentAIId {
            AIManager.shared.updateAIStats(
                ai: AI(id: aiID, name: "", category: .friend, description: "", avatar: "", backgroundColor: "", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
                interaction: .messaged
            )
        }
    }
    
    private func saveMessages() {
        if let aiID = currentAIId, let key = StorageService.StorageKey.messages(forAI: aiID) {
            storageService.save(messages, forKey: key)
        } else if let squadID = currentSquadId, let key = StorageService.StorageKey.messages(forSquad: squadID) {
            storageService.save(messages, forKey: key)
        }
    }

    
    private func setupSubscriptions() {
        // Add any necessary publishers/subscribers
    }
    
    // MARK: - Mock Response Simulation
    
    private func simulateAIResponse(forLocation: Bool = false) {
        isTyping = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...2)) {
            let response = Message(
                id: UUID(),
                content: self.generateMockResponse(forLocation: forLocation),
                timestamp: Date(),
                type: .text,
                sender: self.currentSquadId != nil ? .squad(self.currentSquadId!) : .ai(self.currentAIId!)
            )
            
            self.isTyping = false
            self.addMessage(response)
        }
    }
    
    private func generateMockResponse(forLocation: Bool) -> String {
        if forLocation {
            return "I notice you're at a new location! Would you like any specific information about this area?"
        } else {
            let responses = [
                "That's interesting! Tell me more about that.",
                "I understand. How does that make you feel?",
                "Thank you for sharing that with me.",
                "I see what you mean. Let's explore that further.",
                "That's a great point! Here's what I think..."
            ]
            return responses.randomElement() ?? responses[0]
        }
    }
}

// MARK: - Storage Key Extension
extension StorageService.StorageKey {
    static func messages(forAI aiID: UUID) -> StorageService.StorageKey? {
        guard let key = StorageService.StorageKey(rawValue: "messages_ai_\(aiID.uuidString)") else {
            print("Failed to generate StorageKey for AI")
            return nil
        }
        return key
    }

    static func messages(forSquad squadID: UUID) -> StorageService.StorageKey? {
        guard let key = StorageService.StorageKey(rawValue: "messages_squad_\(squadID.uuidString)") else {
            print("Failed to generate StorageKey for Squad")
            return nil
        }
        return key
    }
}
