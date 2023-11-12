//
//  ChatSidebarListView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 05/11/23.
//

import SwiftUI

struct ChatSidebarListView: View {
    @Environment(CommandViewModel.self) private var commandViewModel
    @Environment(ChatViewModel.self) private var chatViewModel
    
    var body: some View {
        @Bindable var commandViewModelBindable = commandViewModel
        
        List(selection: $commandViewModelBindable.selectedChat) {
            ForEach(chatViewModel.chats) { chat in
                Label(chat.name, systemImage: "bubble")
                    .contextMenu {
                        ChatContextMenu(commandViewModel, for: chat)
                    }
                    .tag(chat)
            }
        }
        .listStyle(.sidebar)
        .task {
            try? chatViewModel.fetch()
        }
        .toolbar {
            ToolbarItemGroup {
                Spacer()
                
                Button("New Chat", systemImage: "square.and.pencil") {
                    commandViewModel.isAddChatViewPresented = true
                }
                .buttonStyle(.accessoryBar)
                .help("New Chat (⌘ + N)")
            }
        }
        .navigationDestination(for: Chat.self) { chat in
            MessageView(for: chat)
        }
        .sheet(
            isPresented: $commandViewModelBindable.isAddChatViewPresented
        ) {
            AddChatView() { createdChat in
                self.commandViewModel.selectedChat = createdChat
            }
        }
        .sheet(
            isPresented: $commandViewModelBindable.isRenameChatViewPresented
        ) {
            if let chatToRename = commandViewModel.chatToRename {
                RenameChatView(for: chatToRename)
            }
        }
        .confirmationDialog(
            AppMessages.chatDeletionTitle,
            isPresented: $commandViewModelBindable.isDeleteChatConfirmationPresented
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive, action: deleteAction)
        } message: {
            Text(AppMessages.chatDeletionMessage)
        }
        .dialogSeverity(.critical)
    }
    
    func deleteAction() {
        guard let chatToDelete = commandViewModel.chatToDelete else { return }
        try? chatViewModel.delete(chatToDelete)
        
        commandViewModel.chatToDelete = nil
        commandViewModel.selectedChat = nil
    }
}
