//
//  AIWheelView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct AIWheelView: View {
    let ais: [AI]
    @Binding var selectedAI: AI?
    let onAISelected: (AI) -> Void

    @GestureState private var dragOffset: CGFloat = 0
    @State private var currentOffset: CGFloat = 0

    let itemSize: CGFloat = 80
    let spacing: CGFloat = 20
    let visibleItems: Int = 5
    let loopedItems: Int = 3  // Number of duplicate items appended on each side

    // Loop the array for infinite scrolling.
    var loopedAIs: [AI] {
        Array(ais.suffix(loopedItems)) + ais + Array(ais.prefix(loopedItems))
    }

    var body: some View {
        // Carousel width fits exactly 5 items.
        let carouselWidth = itemSize * CGFloat(visibleItems) + spacing * CGFloat(visibleItems - 1)
        GeometryReader { geometry in
            ZStack {
                // HStack with the looped items.
                HStack(spacing: spacing) {
                    ForEach(Array(loopedAIs.enumerated()), id: \.element.id) { index, ai in
                        AIAvatar(
                            ai: ai,
                            isSelected: isCenterAI(index: index, carouselWidth: carouselWidth),
                            hasNewMessage: false,
                            isOnCall: false
                        )
                        .frame(width: itemSize, height: itemSize)
                        .scaleEffect(scaleEffect(for: index, carouselWidth: carouselWidth))
                    }
                }
                .frame(width: carouselWidth, alignment: .leading)
                .offset(x: currentOffset + dragOffset)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                            // Optionally: SystemSound.playForAIWheel()
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                snapToNearest(carouselWidth: carouselWidth,
                                              predictedOffset: value.predictedEndTranslation.width)
                            }
                        }
                )
                // Blue circle overlay indicating the center.
                Circle()
                    .stroke(Color.blue, lineWidth: 4)
                    .frame(width: itemSize + 10, height: itemSize + 10)
            }
            .frame(width: carouselWidth, height: itemSize * 2)
            .clipped()
            .onAppear {
                // Set initial offset so the first real item is centered.
                // The original items start at index = loopedItems.
                let initialIndex = loopedItems
                // Center of carousel is at carouselWidth/2.
                // Each item’s center is: index*(itemSize+spacing)+itemSize/2.
                currentOffset = carouselWidth/2 - (CGFloat(initialIndex) * (itemSize + spacing) + itemSize/2)
            }
        }
        .frame(width: carouselWidth, height: itemSize * 2)
    }

    // Scale each item based on its distance from the carousel's center.
    private func scaleEffect(for index: Int, carouselWidth: CGFloat) -> CGFloat {
        let itemCenter = CGFloat(index) * (itemSize + spacing) + itemSize/2 + currentOffset + dragOffset
        let distance = abs(itemCenter - carouselWidth/2)
        let maxDistance = itemSize + spacing  // Threshold distance for scaling effect
        return max(1 - (distance / maxDistance) * 0.3, 0.7)
    }

    // Consider an item "centered" if its center is within half an item’s width of the carousel’s center.
    private func isCenterAI(index: Int, carouselWidth: CGFloat) -> Bool {
        let itemCenter = CGFloat(index) * (itemSize + spacing) + itemSize/2 + currentOffset + dragOffset
        return abs(itemCenter - carouselWidth/2) < (itemSize / 2)
    }

    // Snap to the nearest item so its center aligns with the carousel's center,
    // and adjust the offset if we've scrolled into the duplicate regions.
    private func snapToNearest(carouselWidth: CGFloat, predictedOffset: CGFloat) {
        let itemSpacing = itemSize + spacing
        let totalOffset = currentOffset + predictedOffset
        // Determine which item should snap to center.
        let targetIndex = round((carouselWidth/2 - totalOffset - itemSize/2) / itemSpacing)
        let newOffset = carouselWidth/2 - (targetIndex * itemSpacing + itemSize/2)
        currentOffset = newOffset

        // Adjust for infinite loop by shifting the offset when in duplicate regions.
        let currentIndex = targetIndex
        if currentIndex < CGFloat(loopedItems) {
            currentOffset -= CGFloat(ais.count) * itemSpacing
        } else if currentIndex >= CGFloat(ais.count + loopedItems) {
            currentOffset += CGFloat(ais.count) * itemSpacing
        }

        // Compute selected AI from the original array.
        let indexInLooped = Int(targetIndex)
        let wrappedIndex = (indexInLooped - loopedItems + ais.count) % ais.count
        let selected = ais[wrappedIndex]
        if selectedAI?.id != selected.id {
            onAISelected(selected)
            // Optionally: SystemSound.playForAISelection() and HapticManager.performAISelection()
        }
    }
}

struct AIAvatar: View {
    let ai: AI
    let isSelected: Bool
    let hasNewMessage: Bool
    let isOnCall: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.9))
                .overlay(
                    Group {
                        if ai.isSquad {
                            SquadAvatarContent(ai: ai)
                        } else {
                            Text(String(ai.name.prefix(1)))
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    }
                )
                .overlay(
                    Circle()
                        .stroke(avatarBorderColor, lineWidth: isSelected ? 3 : 0)
                )
            VStack {
                HStack {
                    Spacer()
                    if hasNewMessage {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 12, height: 12)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                    if isOnCall {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                            .padding(4)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                }
                Spacer()
            }
            .padding(4)
        }
        .frame(width: isSelected ? 90 : 80, height: isSelected ? 90 : 80)
        .shadow(radius: isSelected ? 8 : 4)
        .overlay(ai.isSquad ? squadIndicator : nil)
    }

    private var avatarBorderColor: Color {
        ai.isSquad ? .purple : .blue
    }

    private var squadIndicator: some View {
        Image(systemName: "person.3.fill")
            .font(.system(size: 12))
            .foregroundColor(.white)
            .padding(4)
            .background(Color.purple)
            .clipShape(Circle())
            .offset(x: -20, y: -20)
    }
}

struct SquadAvatarContent: View {
    let ai: AI

    var body: some View {
        ZStack {
            ForEach(0..<(ai.squadMembers?.count ?? 0), id: \.self) { index in
                Circle()
                    .fill(Color.purple.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .offset(x: offsetFor(index: index).x, y: offsetFor(index: index).y)
            }
            Text(ai.name.prefix(10))
                .font(.title3)
                .foregroundColor(.purple)
        }
    }

    private func offsetFor(index: Int) -> CGPoint {
        let radius: CGFloat = 10
        let angle = (2 * .pi / Double(ai.squadMembers?.count ?? 1)) * Double(index)
        return CGPoint(x: CGFloat(cos(angle)) * radius,
                       y: CGFloat(sin(angle)) * radius)
    }
}


#Preview {
    let mockSquad = AI(
        id: UUID(),
        name: "Super Squad",
        category: .specialist,
        description: "Squad Groupchat",
        avatar: "",
        backgroundColor: "default",
        isLocked: false,
        stats: AI.AIStats(
            messagesCount: 0,
            responseTime: 0,
            userRating: 0,
            lastInteraction: Date()
        ),
        securityEnabled: false,
        isSquad: true,
        squadMembers: [
            AI(id: UUID(), name: "AI 1", category: .friend, description: "", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
            AI(id: UUID(), name: "AI 2", category: .professional, description: "", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false)
        ]
    )
    
    return AIWheelView(
        ais: [
            mockSquad,
            AI(id: UUID(), name: "Friend", category: .friend, description: "Your AI friend", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
            AI(id: UUID(), name: "Pro", category: .professional, description: "Professional AI", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
            AI(id: UUID(), name: "Guy Fiery", category: .friend, description: "Your AI friend", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
            AI(id: UUID(), name: "Gordon Ramzy", category: .friend, description: "Your AI friend", avatar: "", backgroundColor: "default", isLocked: false, stats: AI.AIStats(messagesCount: 0, responseTime: 0, userRating: 0, lastInteraction: Date()), securityEnabled: false),
        ],
        selectedAI: .constant(nil),
        onAISelected: { _ in }
    )
    .frame(height: 200)
    .background(Color.gray.opacity(0.2))
}

