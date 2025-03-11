//
//  ChatBubble.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/28/24.
//

import SwiftUI

struct MediaContentView: View {
    let type: Message.MediaType
    let message: Message
    
    var body: some View {
        switch type {
        case .image:
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
        case .video:
            Image(systemName: "play.rectangle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
        case .audio:
            HStack {
                Image(systemName: "waveform")
                Text("Audio message")
            }
        }
    }
}

struct LinkContentView: View {
    let type: Message.LinkType
    let message: Message
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: linkIcon)
                Text(linkTitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(message.content)
                .foregroundColor(message.sender == Message.MessageSender.user ? .white : .primary)

        }
    }
    
    private var linkIcon: String {
        switch type {
        case .tiktok:
            return "play.square"
        case .youtube:
            return "play.rectangle"
        case .website:
            return "link"
        }
    }
    
    private var linkTitle: String {
        switch type {
        case .tiktok:
            return "TikTok"
        case .youtube:
            return "YouTube"
        case .website:
            return "Website"
        }
    }
}

struct LocationContextView: View {
    let context: Message.LocationContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(context.placeName)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("\(context.duration.formatted()) at this location")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // User message
        ChatBubble(
            message: Message(
                id: UUID(),
                content: "Hello! How are you?",
                timestamp: Date(),
                type: .text,
                sender: .user
            )
        )
        
        // AI message
        ChatBubble(
            message: Message(
                id: UUID(),
                content: "I'm doing great! Thanks for asking.",
                timestamp: Date(),
                type: .text,
                sender: .ai(UUID())
            )
        )
    }
    .padding()
}
