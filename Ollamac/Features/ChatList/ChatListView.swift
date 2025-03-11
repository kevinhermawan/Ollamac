//
//  ChatListView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 12/03/25.
//

import SwiftUI
import ViewCondition

struct ChatListView: View {
    @Environment(ChatManager.self) private var chatManager
    
    @State private var isDeleteConfirmationPresented: Bool = false
    
    var body: some View {
        @Bindable var chatManager = chatManager
        
        List(selection: $chatManager.selectedChatId) {
            ForEach(chatManager.chats) { chat in
                ChatListItemView(
                    for: chat,
                    isSelected: chat.id == chatManager.selectedChatId,
                    isEditing: chat.id == chatManager.chatToEdit?.id,
                    onBeginEditing: { chatManager.chatToEdit = chat },
                    onEndEditing: { chatManager.chatToEdit = nil }
                )
                .contextMenu {
                    Button("Delete") {
                        chatManager.chatToDelete = chat
                        isDeleteConfirmationPresented = true
                    }
                    .hide(if: chatManager.chats.count <= 1)
                    
                    Divider()
                    
                    Button("Rename") {
                        chatManager.selectedChatId = chat.id
                        chatManager.chatToEdit = chat
                    }
                }
            }
        }
        .onAppear {
            if chatManager.chats.isEmpty {
                chatManager.createNewChat()
            }
            
            chatManager.setSelectedChat()
        }
        .confirmationDialog("Are you sure want to delete this chat?", isPresented: $isDeleteConfirmationPresented) {
            Button("Delete", role: .destructive, action: chatManager.deleteChat)
            Button("Cancel", role: .cancel, action: {})
        } message: {
            Text("This operation cannot be undone.")
        }
    }
}
