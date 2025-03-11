//
//  AttachmentsView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 1/9/2025
//

import SwiftUI

struct AttachmentsView: View {
    let attachments: [Message.Attachment]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(attachments, id: \.id) { attachment in
                    renderAttachment(attachment)
                }
            }
            .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func renderAttachment(_ attachment: Message.Attachment) -> some View {
        switch attachment.type {
        case .image:
            // Add this content block
            do {
                AsyncImage(url: attachment.url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } placeholder: {
                    ProgressView(topAIs: [
                        AI(id: UUID(),
                           name: "Friend AI",
                           category: .friend,
                           description: "Your AI friend",
                           avatar: "",
                           backgroundColor: "default",
                           isLocked: false,
                           stats: AI.AIStats(messagesCount: 75,
                                           responseTime: 1.0,
                                           userRating: 4.5,
                                           lastInteraction: Date()),
                           securityEnabled: false)
                    ])
                }
            }
        case .video:
            Image(systemName: "video")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
        case .audio:
            Image(systemName: "waveform")
                .font(.system(size: 36))
                .padding()
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
}

struct AttachmentsView_Previews: PreviewProvider {
    static var previews: some View {
        AttachmentsView(
            attachments: [
                Message.Attachment(id: UUID(), url: URL(string: "https://example.com/image.jpg")!, type: .image, thumbnail: nil),
                Message.Attachment(id: UUID(), url: URL(string: "https://example.com/video.mp4")!, type: .video, thumbnail: nil),
                Message.Attachment(id: UUID(), url: URL(string: "https://example.com/audio.mp3")!, type: .audio, thumbnail: nil)
            ]
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
