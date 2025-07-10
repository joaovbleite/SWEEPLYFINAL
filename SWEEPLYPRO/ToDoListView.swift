//
//  ToDoListView.swift
//  SWEEPLYPRO
//
//  Created on 7/2/25.
//

import SwiftUI

struct TodoItem: Identifiable {
    let id = UUID()
    let iconName: String
    let iconBackground: Color
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
}

struct ToDoListView: View {
    @State private var showFeaturePromoModal = false
    @State private var showNewClientView = false
    
    // Sample todo items
    var todoItems: [TodoItem] {
        [
            TodoItem(
                iconName: "doc.text",
                iconBackground: Color(hex: "#EAF0FF"),
                iconColor: Color(hex: "#246BFD"),
                title: "Create a winning quote",
                subtitle: "Boost your revenue with custom quotes",
                action: { /* Action for creating quote */ }
            ),
            TodoItem(
                iconName: "person.badge.plus",
                iconBackground: Color(hex: "#EAF0FF"),
                iconColor: Color(hex: "#246BFD"),
                title: "Add your first client",
                subtitle: "Start building your customer database",
                action: { showNewClientView = true }
            ),
            TodoItem(
                iconName: "desktopcomputer",
                iconBackground: Color(hex: "#EAF0FF"),
                iconColor: Color(hex: "#246BFD"),
                title: "Try Sweeply on desktop",
                subtitle: "Check out the full suite of time-saving features",
                action: { showFeaturePromoModal = true }
            )
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Text("To do")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "#0A0A0A"))
            
            // Todo items
            VStack(spacing: 0) {
                ForEach(todoItems) { item in
                    TodoItemView(item: item)
                    
                    if item.id != todoItems.last?.id {
                        Divider()
                            .background(Color(hex: "#E0E0E0"))
                            .padding(.leading, 56)
                    }
                }
            }
            .background(Color.clear)
            .cornerRadius(16)
        }
        .padding(.horizontal, 8)
        .sheet(isPresented: $showFeaturePromoModal) {
            FeaturePromoModalView()
        }
        .sheet(isPresented: $showNewClientView) {
            NewClientView()
        }
    }
}

struct TodoItemView: View {
    let item: TodoItem
    
    var body: some View {
        Button(action: item.action) {
            HStack(spacing: 12) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(item.iconBackground)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: item.iconName)
                        .font(.system(size: 20))
                        .foregroundColor(item.iconColor)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#0A0A0A"))
                    
                    Text(item.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#5D6A76"))
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#8D9BA8"))
            }
            .padding(16)
            .background(Color.clear)
            .cornerRadius(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ToDoListView()
        .padding(.vertical)
        .background(Color(hex: "#F5F5F5"))
} 