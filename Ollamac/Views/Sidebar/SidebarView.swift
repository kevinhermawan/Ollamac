//
//  SidebarView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/2/24.
//

import Defaults
import SwiftUI
import ViewCondition

struct SidebarView: View {
    @Environment(ChatViewModel.self) private var chatViewModel
    @Environment(MessageViewModel.self) private var messageViewModel
    
    private var todayChats: [Chat] {
        let calendar = Calendar.current
        
        return chatViewModel.chats.filter { calendar.isDateInToday($0.modifiedAt) }
    }
    
    private var yesterdayChats: [Chat] {
        let calendar = Calendar.current
        
        return chatViewModel.chats.filter { calendar.isDateInYesterday($0.modifiedAt) }
    }
    
    private var previousDaysChats: [Chat] {
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        
        return chatViewModel.chats.filter { $0.modifiedAt < calendar.startOfDay(for: twoDaysAgo) }
    }
    
    private var deleteConfirmationTitle: String {
        if chatViewModel.selectedChats.count > 1 {
            return "Delete Chats"
        }
        
        return "Delete Chat"
    }
    
    private var deleteConfirmationMessage: String {
        if chatViewModel.selectedChats.count > 1 {
            return "Are you sure you want to delete these chats?"
        }
        
        return "Are you sure you want to delete this chat?"
    }
    
    var body: some View {
        @Bindable var chatViewModelBindable = chatViewModel
        
        List(selection: $chatViewModelBindable.selectedChats) {
            Section("Today") {
                ForEach(todayChats) { chat in
                    SidebarListItemView(chatViewModel: chatViewModel, name: chat.name, message: chat.messages.first?.response)
                        .tag(chat)
                }
            }
            .hide(if: todayChats.isEmpty, removeCompletely: true)
            
            Section("Yesterday") {
                ForEach(yesterdayChats) { chat in
                    SidebarListItemView(chatViewModel: chatViewModel, name: chat.name, message: chat.messages.first?.response)
                        .tag(chat)
                }
            }
            .hide(if: yesterdayChats.isEmpty, removeCompletely: true)
            
            Section("Previous days") {
                ForEach(previousDaysChats) { chat in
                    SidebarListItemView(chatViewModel: chatViewModel, name: chat.name, message: chat.messages.first?.response)
                        .tag(chat)
                }
            }
            .hide(if: previousDaysChats.isEmpty, removeCompletely: true)
        }
        .listStyle(.sidebar)
        .toolbar {
            SidebarToolbarContent {
                chatViewModel.create(model: Defaults[.defaultModel])
            }
        }
        .alert("Rename Chat", isPresented: $chatViewModelBindable.isRenameChatPresented) {
            TextField("Chat name", text: $chatViewModelBindable.chatNameTemp)
            Button("Cancel", role: .cancel, action: {})
            Button("Rename", action: chatViewModel.rename)
        }
        .confirmationDialog(deleteConfirmationTitle, isPresented: $chatViewModelBindable.isDeleteConfirmationPresented) {
            Button("Cancel", role: .cancel, action: {})
            Button("Delete", role: .destructive, action: chatViewModel.remove)
        } message: {
            Text(deleteConfirmationMessage)
        }
        .onAppear(perform: chatViewModel.load)
        .onChange(of: chatViewModel.chats) { _, chats in
            if let chat = chats.first {
                chatViewModel.selectedChats = [chat]
            } else {
                chatViewModel.selectedChats = []
                messageViewModel.messages = []
            }
        }
        .onChange(of: chatViewModel.selectedChats) { _, selectedChats in
            if selectedChats.count > 1 {
                chatViewModel.activeChat = nil
                messageViewModel.load(of: nil)
            } else {
                let selectedChatsArray = Array(selectedChats)
                guard let activeChat = selectedChatsArray.first else { return }
                
                chatViewModel.activeChat = activeChat
                messageViewModel.load(of: activeChat)
            }
        }
    }
}
