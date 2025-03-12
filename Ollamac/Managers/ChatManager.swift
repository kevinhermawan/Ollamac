//
//  ChatManager.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 12/03/25.
//

import Defaults
import DefaultsMacros
import SwiftData
import SwiftUI

@Observable
final class ChatManager {
    private let modelContext: ModelContext
    
    var chats: [Chat] = []
    
    @ObservableDefault(.selectedChatId)
    @ObservationIgnored
    var selectedChatId: Chat.ID?
    
    var selectedChat: Chat? {
        chats.first(where: { $0.id == selectedChatId })
    }
    
    var chatToEdit: Chat?
    var chatToDelete: Chat?
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        fetchChats()
//        setSelectedChat()
    }
    
    func fetchChats() {
        let sortDescriptors: [SortDescriptor<Chat>] = [
            SortDescriptor(\.modifiedAt, order: .reverse)
        ]
        
        let fetchDescriptor = FetchDescriptor<Chat>(sortBy: sortDescriptors)
        
        do {
            self.chats = try modelContext.fetch(fetchDescriptor)
        } catch {
            self.chats = []
        }
    }
    
    func setSelectedChat() {
        if selectedChatId == nil || !chats.contains(where: { $0.id == selectedChatId }) {
            selectedChatId = chats.first?.id
        }
    }
    
    func createNewChat() {
        let chat = Chat(name: "New Chat")
        
        modelContext.insert(chat)
        chats.insert(chat, at: 0)
        
        self.selectedChatId = chat.id
    }
    
    func deleteChat() {
        guard let chatToDelete else { return }
        
        modelContext.delete(chatToDelete)
        chats.removeAll(where: { $0.id == chatToDelete.id })
        
        if selectedChatId == chatToDelete.id {
            selectedChatId = chats.first?.id
        }
        
        self.chatToDelete = nil
    }
}
