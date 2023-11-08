//
//  ChatSidebarListView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 05/11/23.
//

import OptionalKit
import SwiftUI

struct ChatSidebarListView: View {
    @Environment(CommandViewModel.self) private var commandViewModel
    @Environment(ChatViewModel.self) private var chatViewModel
    
    var body: some View {
        @Bindable var commandViewModel = commandViewModel
        
        List(selection: $commandViewModel.selectedChat) {
            ForEach(chatViewModel.chats) { chat in
                Label(chat.name, systemImage: "bubble")
                    .contextMenu {
                        ChatContextMenu(commandViewModel, for: chat)
                    }
                    .tag(chat)
            }
        }
        .toolbar {
            toolbarItem()
        }
        .task {
            chatViewModel.fetch()
        }
        .navigationDestination(for: Chat.self) { chat in
            MessageView(for: chat)
        }
        .sheet(isPresented: $commandViewModel.isAddChatViewPresented) {
            AddChatView() { createdChat in
                self.commandViewModel.selectedChat = createdChat
            }
        }
        .sheet(isPresented: $commandViewModel.isRenameChatViewPresented) {
            if let chatToRename = commandViewModel.chatToRename {
                RenameChatView(for: chatToRename)
            }
        }
        .confirmationDialog(
            Constants.deleteChatConfirmationTitle,
            isPresented: $commandViewModel.isDeleteChatConfirmationPresented
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                if let chatToDelete = commandViewModel.chatToDelete {
                    self.chatViewModel.delete(chatToDelete)
                    self.commandViewModel.chatToDelete = nil
                    self.commandViewModel.selectedChat = nil
                }
            }
        } message: {
            Text(Constants.deleteChatConfirmationMessage)
        }
        .dialogSeverity(.critical)
    }
    
    private func toolbarItem() -> some ToolbarContent {
        ToolbarItemGroup {
            Spacer()
            
            Button("New Chat", systemImage: "square.and.pencil") {
                commandViewModel.isAddChatViewPresented = true
            }
            .buttonStyle(.accessoryBar)
        }
    }
}

#Preview {
    ChatSidebarListView()
}
