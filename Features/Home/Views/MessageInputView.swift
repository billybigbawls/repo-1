//
//  MessageInputView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct MessageInputView: View {
    @Binding var text: String
    let onSend: () -> Void
    let onAttachment: () -> Void
    let onCamera: () -> Void
    
    @State private var isShowingAttachmentMenu = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Attachment menu if showing
            if isShowingAttachmentMenu {
                AttachmentMenu(
                    onCamera: onCamera,
                    onAttachment: onAttachment
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Main input bar
            HStack(spacing: 12) {
                // Attach button
                Button(action: {
                    withAnimation(.spring()) {
                        isShowingAttachmentMenu.toggle()
                    }
                    HapticManager.selection()
                }) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                        .rotationEffect(.degrees(isShowingAttachmentMenu ? 45 : 0))
                }
                .padding(.leading)
                
                // Text input
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text("Message...")
                            .foregroundColor(.gray)
                    }
                    
                    TextField("", text: $text)
                        .focused($isFocused)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding(.vertical, 8)
                
                // Send button
                if !text.isEmpty {
                    Button(action: {
                        onSend()
                        HapticManager.lightImpact()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(height: 44)
            .background(
                Color.white.opacity(0.2)
                    .glassMorphic()
            )
            .clipShape(RoundedRectangle(cornerRadius: Constants.cornerRadius))
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}

struct AttachmentMenu: View {
    let onCamera: () -> Void
    let onAttachment: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            AttachmentButton(
                icon: "camera.fill",
                label: "Camera",
                action: onCamera
            )
            
            AttachmentButton(
                icon: "photo.fill",
                label: "Gallery",
                action: onAttachment
            )
            
            AttachmentButton(
                icon: "doc.fill",
                label: "File",
                action: onAttachment
            )
        }
        .padding()
        .background(
            Color.white.opacity(0.1)
                .glassMorphic()
        )
    }
}

struct AttachmentButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
            HapticManager.selection()
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .frame(width: 50, height: 50)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
                
                Text(label)
                    .font(.caption2)
            }
        }
        .foregroundColor(.primary)
    }
}

struct MessageInputView_Previews: PreviewProvider {
    static var previews: some View {
        MessageInputView(
            text: .constant(""),
            onSend: {},
            onAttachment: {},
            onCamera: {}
        )
        .padding()
        .background(Color.gray.opacity(0.2))
        .previewLayout(.sizeThatFits)
    }
}
