//v1
//  ResponseLengthControl.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/28/24.
//

import SwiftUI

struct ResponseLengthControl: View {
    @Binding var selection: ResponseLength
    @State private var isExpanded = false
    
    var body: some View {
        VStack {
            // Main control
            HStack(spacing: 20) {
                ForEach([ResponseLength.small, .medium, .large], id: \.self) { length in
                    Button(action: {
                        withAnimation(.spring()) {
                            selection = length
                            HapticManager.selection()
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(length.symbol)
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text(length.displayText)
                                .font(.caption2)
                                .opacity(isExpanded ? 1 : 0)
                                .frame(height: isExpanded ? nil : 0)
                        }
                        .frame(width: 40)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selection == length ? Color.blue : Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .foregroundColor(selection == length ? .white : .primary)
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .glassMorphic()
            )
            
            // Expand button
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: "chevron.up")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
    }
}

extension ResponseLength {
    var symbol: String {
        switch self {
        case .small:
            return "S"
        case .medium:
            return "M"
        case .large:
            return "L"
        }
    }
    
    var displayText: String {
        switch self {
        case .small:
            return "Brief"
        case .medium:
            return "Normal"
        case .large:
            return "Detailed"
        }
    }
    
    var approximateWordCount: String {
        switch self {
        case .small:
            return ">20"
        case .medium:
            return ">50"
        case .large:
            return ">100"
        }
    }
}

// Expanded version with more information
struct ExpandedResponseLengthControl: View {
    @Binding var selection: ResponseLength
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Response Length")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Choose how detailed you want the AI's responses to be.")
                .foregroundColor(.secondary)
            
            ForEach([ResponseLength.small, .medium, .large], id: \.self) { length in
                Button(action: {
                    withAnimation(.spring()) {
                        selection = length
                        HapticManager.selection()
                        dismiss()
                    }
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(length.displayText)
                                    .font(.headline)
                                
                                Text(length.symbol)
                                    .font(.caption)
                                    .padding(4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color.gray.opacity(0.2))
                                    )
                            }
                            
                            Text("\(length.approximateWordCount) words")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selection == length {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .glassMorphic()
                    )
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    VStack(spacing: 40) {
        ResponseLengthControl(selection: .constant(.medium))
        
        ExpandedResponseLengthControl(selection: .constant(.medium))
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
