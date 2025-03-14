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
    @Published var error: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService.shared
    
    // MARK: - Initialization
    
    init() {
        loadLocalMessages()
    }
    
    // MARK: - Public Methods
    
    /// Sends a message to the AI and gets a response
    func sendMessage(_ content: String, to ai: AI? = nil, attachments: [Message.Attachment]? = nil) {
        guard let user = UserManager.shared.currentUser else {
            self.error = "User not found"
            return
        }
        
        // Create a local message to show immediately
        let message = Message(
            id: UUID().uuidString,
            content: content,
            createdAt: Date(),
            isAI: false,
            sender: user,
            ai: nil,
            attachments: attachments
        )
        
        // Add message to UI immediately
        messages.append(message)
        saveLocalMessages()
        
        // Update AI stats
        if let ai = ai {
            AIManager.shared.updateAIStats(
                ai: ai,
                interaction: .messaged
            )
        }
        
        // Indicate we're waiting for a response
        isTyping = true
        
        // Prepare the request parameters
        let requestSettings = RequestSettings(
            maxTokens: APIConfig.maxTokens,
            temperature: APIConfig.temperature,
            language: Locale.current.languageCode
        )
        
        let request = ChatRequest(
            message: content,
            aiId: ai?.id,
            settings: requestSettings
        )
        
        // Handle attachments if present
        var parameters: [String: Any]
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(request)
            guard var params = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw NetworkError.requestFailed(NSError(domain: "ChatManager", code: 1, userInfo: nil))
            }
            
            // Add attachment information if present
            if let attachments = attachments, !attachments.isEmpty {
                params["hasAttachments"] = true
                // For now, we're just signaling that attachments exist
                // In a full implementation, you'd upload these separately
            }
            
            parameters = params
        } catch {
            self.error = "Failed to prepare message: \(error.localizedDescription)"
            isTyping = false
            return
        }
        
        // Use async/await with Task
        Task {
            do {
                let response: ChatResponse = try await networkService.request(
                    endpoint: .aiGenerate,
                    method: .post,
                    parameters: parameters,
                    requiresAuth: UserManager.shared.isAuthenticated()
                )
                
                await MainActor.run {
                    // Create AI message
                    let aiMessage = Message(
                        id: UUID().uuidString,
                        content: response.content,
                        createdAt: Date(),
                        isAI: true,
                        sender: nil,
                        ai: ai
                    )
                    
                    // Add metadata to the message
                    aiMessage.metadata = Message.Metadata(
                        tokens: response.metadata.tokens,
                        processingTime: response.metadata.processingTime,
                        aiPersonality: response.metadata.aiPersonality,
                        promptTokens: response.metadata.promptTokens,
                        completionTokens: response.metadata.completionTokens
                    )
                    
                    // Update UI
                    self.messages.append(aiMessage)
                    self.isTyping = false
                    self.saveLocalMessages()
                }
            } catch {
                await MainActor.run {
                    self.handleSendMessageError(error)
                }
            }
        }
    }
    
    /// Loads the chat history from the server
    func loadMessageHistory(limit: Int = 50, offset: Int = 0) {
        guard UserManager.shared.isAuthenticated() else {
            // Load only local messages if not authenticated
            self.loadLocalMessages()
            return
        }
        
        let parameters = ["limit": limit, "offset": offset]
        
        networkService.request(
            endpoint: .messages,
            method: .get,
            parameters: parameters,
            requiresAuth: true
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    // Fallback to local messages
                    self?.loadLocalMessages()
                }
            },
            receiveValue: { [weak self] (response: MessagesResponse) in
                guard let self = self else { return }
                
                // Convert API messages to local Message model
                let mappedMessages = response.messages.map { message -> Message in
                    let aiId = message.aiId
                    let ai = aiId != nil ? AIManager.shared.getAI(withId: aiId!) : nil
                    
                    return Message(
                        id: message.id,
                        content: message.content,
                        createdAt: message.createdAt,
                        isAI: message.isAI,
                        sender: message.isAI ? nil : UserManager.shared.currentUser,
                        ai: ai
                    )
                }
                
                self.messages = mappedMessages
                self.saveLocalMessages()
            }
        )
        .store(in: &cancellables)
    }
    
    /// Clears all messages
    func clearMessages() {
        messages = []
        saveLocalMessages()
    }
    
    // MARK: - Helper Methods
    
    private func handleSendMessageError(_ error: Error) {
        let errorMessage: String
        
        if let networkError = error as? NetworkError {
            switch networkError {
            case .noInternetConnection:
                errorMessage = "No internet connection. Please try again when you're back online."
            case .unauthorized:
                errorMessage = "Please log in to continue your conversation."
            case .serverError:
                errorMessage = "Our AI is taking a brief break. Please try again in a moment."
            default:
                errorMessage = "Something went wrong. Please try again."
            }
        } else {
            errorMessage = "Something went wrong. Please try again."
        }
        
        // Add error message to chat as system message
        let errorAI = AIManager.shared.defaultAI
        let errorResponse = Message(
            id: UUID().uuidString,
            content: errorMessage,
            createdAt: Date(),
            isAI: true,
            sender: nil,
            ai: errorAI
        )
        
        self.messages.append(errorResponse)
        self.error = errorMessage
        self.isTyping = false
        self.saveLocalMessages()
    }
    
    // MARK: - Persistence Methods
    
    private func saveLocalMessages() {
        do {
            let data = try JSONEncoder().encode(messages)
            UserDefaults.standard.set(data, forKey: "chatMessages")
        } catch {
            print("Failed to save messages: \(error)")
        }
    }
    
    private func loadLocalMessages() {
        guard let data = UserDefaults.standard.data(forKey: "chatMessages") else {
            return
        }
        
        do {
            let localMessages = try JSONDecoder().decode([Message].self, from: data)
            self.messages = localMessages
        } catch {
            print("Failed to load messages: \(error)")
        }
    }
}

// MARK: - Message+Metadata

extension Message {
    struct Metadata: Codable {
        var tokens: Int
        var processingTime: Double
        var aiPersonality: String
        var promptTokens: Int?
        var completionTokens: Int?
    }
    
    var metadata: Metadata? {
        get {
            _metadata
        }
        set {
            _metadata = newValue
        }
    }
    
    private var _metadata: Metadata?
}

// MARK: - Helper Extensions for AIManager

extension AIManager {
    func getAI(withId id: String) -> AI? {
        return availableAIs.first { $0.id == id }
    }
}
