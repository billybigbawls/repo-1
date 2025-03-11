//
//  CategoryView.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import SwiftUI

struct CategoryView: View {
    let categories: [AI.AICategory]
    @Binding var selectedCategory: AI.AICategory?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Click To Chat!")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    // All category option
                    CategoryCard(
                        category: nil,
                        isSelected: selectedCategory == nil,
                        onTap: { selectedCategory = nil }
                    )
                    
                    // Individual categories
                    ForEach(categories, id: \.self) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategory == category,
                            onTap: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CategoryCard: View {
    let category: AI.AICategory?
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                onTap()
            }
            HapticManager.selection()
        }) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(iconColor)
                }
                
                // Label
                Text(displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
            .frame(width: 100)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: isSelected ? .blue.opacity(0.3) : .black.opacity(0.1),
                           radius: isSelected ? 8 : 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
    }
    
    private var displayName: String {
        if let category = category {
            return category.displayName
        }
        return "All"
    }
    
    private var iconName: String {
        if let category = category {
            switch category {
            case .friend:
                return "person.fill"
            case .professional:
                return "briefcase.fill"
            case .creative:
                return "paintbrush.fill"
            case .utility:
                return "motorcycle.fill"
            case .specialist:
                return "star.fill"
            }
        }
        return "square.grid.2x2.fill"
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .blue.opacity(0.2)
        }
        return Color.gray.opacity(0.1)
    }
    
    private var iconColor: Color {
        if let category = category {
            switch category {
            case .friend:
                return .blue
            case .professional:
                return .purple
            case .creative:
                return .orange
            case .utility:
                return .green
            case .specialist:
                return .yellow
            }
        }
        return .gray
    }
}

// Preview
struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryView(
            categories: [.friend, .professional, .creative, .utility, .specialist],
            selectedCategory: .constant(nil)
        )
        .padding()
        .background(Color.gray.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
}
