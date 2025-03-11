//
//  ChatView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI


private let typingID = UUID()

struct ChatView: View {
    @Binding var messages: [Message]
    @Binding var isTyping: Bool
    let backgroundType: String
    @State private var messageText = ""
    @State private var responseLength: ResponseLength = .medium
    @State private var showAttachmentOptions = false
    
    // New properties for squad support
    let currentAI: AI
    @State private var activeSquadMember: AI?
    
    var body: some View {
        VStack(spacing: 0) {
            // Squad indicator (if applicable)
            if currentAI.isSquad {
                SquadIndicatorView(
                    squad: currentAI,
                    activeAI: $activeSquadMember
                )
                .padding(.vertical, 8)
            }
            
            // Messages ScrollView
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            ChatBubble(
                                message: message,
                                isSquad: currentAI.isSquad,
                                squadMember: getSquadMember(for: message)
                            )
                            .id(message.id)
                        }
                        
                        if isTyping {
                            TypingIndicator(
                                isSquad: currentAI.isSquad,
                                activeAI: activeSquadMember
                            )
                            .id(typingID)
                        }
                    }
                    .padding()
                }
                .onChange(of: messages) { _ in
                    withAnimation {
                        proxy.scrollTo(messages.last?.id ?? typingID, anchor: .bottom)

                    }
                }
            }
            
            // Response Length Control
            ResponseLengthControl(selection: $responseLength)
                .padding(.horizontal)
            
            // Message Input
            VStack(spacing: 8) {
                if showAttachmentOptions {
                    AttachmentMenu(
                        onCamera: handleCamera,
                        onAttachment: handleGallery  // or whatever function you want to use
                    )
                }
                
                MessageInputView(
                    text: $messageText,
                    onSend: sendMessage,
                    onAttachment: { showAttachmentOptions.toggle() },  // Convert binding to closure
                    onCamera: handleCamera
                )
            }
            .padding()
            .background(Color.white.opacity(0.1))
        }
        .background(
            ChatBackgroundView(type: backgroundType)
        )
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        SystemSound.playForMessage(sent: true)
        
        if currentAI.isSquad {
            // Randomly select next squad member to respond
            activeSquadMember = selectNextSquadMember()
        }
        
        HapticManager.performMessageSent()
        messageText = ""
    }
    
    func receiveMessage(_ message: Message) {
        SystemSound.playForMessage(sent: false)
        messages.append(message)
        
        if currentAI.isSquad {
            // Update active squad member for next interaction
            activeSquadMember = selectNextSquadMember()
        }
    }
    
    private func selectNextSquadMember() -> AI? {
        guard let members = currentAI.squadMembers, !members.isEmpty else { return nil }
        return members.randomElement()
    }
    
    private func getSquadMember(for message: Message) -> AI? {
        guard currentAI.isSquad else { return nil }
        
        switch message.sender {
        case .ai(let id):
            return currentAI.squadMembers?.first { $0.id == id }
        default:
            return nil
        }
    }
    
    private func handleCamera() {
        // Handle camera access
    }
    
    private func handleGallery() {
        // Handle gallery access
    }
    
    private func handleFile() {
        // Handle file selection
    }
}

// New Components for Squad Support
struct SquadIndicatorView: View {
    let squad: AI
    @Binding var activeAI: AI?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(squad.squadMembers ?? [], id: \.id) { member in
                    VStack {
                        Circle()
                            .fill(member.id == activeAI?.id ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(member.name.prefix(1))
                                    .foregroundColor(.white)
                            )
                        
                        Text(member.name)
                            .font(.caption)
                            .foregroundColor(member.id == activeAI?.id ? .primary : .secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}



// Modified Components
struct ChatBubble: View {
    let message: Message
    var isSquad: Bool = false
    var squadMember: AI?
    
    var body: some View {
        HStack {
            if case .user = message.sender {
                Spacer()
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading) {
                if isSquad, let member = squadMember {
                    Text(member.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                content
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(backgroundView)
                    .clipShape(BubbleShape(isUser: message.sender == .user))
                
                
                if let attachments = message.attachments {
                    AttachmentsView(attachments: attachments)
                }
            }
            
            if case .user = message.sender {
                EmptyView()
            } else {
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch message.type {
        case .text:
            Text(message.content)
                .foregroundColor(message.sender == .user ? .white : .primary)
        case .media(let type):
            MediaContentView(type: type, message: message)
        case .location:
            Text("📍 Location shared")
                .foregroundColor(message.sender == .user ? .white : .primary)
        case .link(let linkType):
            LinkContentView(type: linkType, message: message)
        }
    }
    
    private var backgroundView: some View {
        Group {
            if case .user = message.sender {
                Color.blue
            } else if isSquad, let member = squadMember {
                if #available(iOS 17.0, *) {
                    Color(member.category.color.opacity(0.2))
                } else {
                    member.category.color.opacity(0.2)  // Replace the comment with actual fallback
                }
            } else {
                Color.white.opacity(0.8)
            }
        }
        .glassMorphic()
    }
    
    struct BubbleShape: Shape {
        let isUser: Bool
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            let radius: CGFloat = 16
            let arrowWidth: CGFloat = 10
            let arrowHeight: CGFloat = 6
            
            // Starting point
            path.move(to: CGPoint(x: isUser ? rect.maxX - radius : rect.minX + radius, y: rect.minY))
            
            // Top edge
            path.addLine(to: CGPoint(x: isUser ? rect.minX + radius : rect.maxX - radius, y: rect.minY))
            
            // Top left/right corner
            if isUser {
                path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                            radius: radius,
                            startAngle: Angle(degrees: -90),
                            endAngle: Angle(degrees: 180),
                            clockwise: true)
            } else {
                path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                            radius: radius,
                            startAngle: Angle(degrees: -90),
                            endAngle: Angle(degrees: 0),
                            clockwise: false)
            }
            
            // Left/right edge
            if isUser {
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - radius))
            } else {
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
            }
            
            // Bottom left/right corner and arrow
            if isUser {
                path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                            radius: radius,
                            startAngle: Angle(degrees: 180),
                            endAngle: Angle(degrees: 90),
                            clockwise: true)
                
                path.addLine(to: CGPoint(x: rect.maxX - arrowWidth, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - arrowHeight))
            } else {
                path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                            radius: radius,
                            startAngle: Angle(degrees: 0),
                            endAngle: Angle(degrees: 90),
                            clockwise: false)
                
                path.addLine(to: CGPoint(x: rect.minX + arrowWidth, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - arrowHeight))
            }
            
            // Bottom edge
            path.addLine(to: CGPoint(x: isUser ? rect.maxX : rect.minX + radius, y: rect.maxY - radius))
            
            // Top right/left corner
            if isUser {
                path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
                            radius: radius,
                            startAngle: Angle(degrees: 0),
                            endAngle: Angle(degrees: -90),
                            clockwise: true)
            } else {
                path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
                            radius: radius,
                            startAngle: Angle(degrees: 180),
                            endAngle: Angle(degrees: -90),
                            clockwise: false)
            }
            
            path.closeSubpath()
            return path
        }
    }
    
    // Rest of your existing components remain the same...
    
    #Preview {
        let mockSquad = AI(
            id: UUID(),
            name: "Dream Team",
            category: .specialist,
            description: "A powerful squad",
            avatar: "",
            backgroundColor: "default",
            isLocked: false,
            stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()),
            securityEnabled: false,
            isSquad: true,
            squadMembers: [
                AI(id: UUID(), name: "AI 1", category: .friend, description: "", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
                AI(id: UUID(), name: "AI 2", category: .professional, description: "", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false)
            ]
        )
        
        return ChatView(
            messages: .constant([]),
            isTyping: .constant(false),
            backgroundType: "default",
            currentAI: mockSquad
        )
    }
}
