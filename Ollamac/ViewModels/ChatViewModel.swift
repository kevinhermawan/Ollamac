//
//  ChatViewModel.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import SwiftData
import SwiftUI

@Observable
final class ChatViewModel {
    private var modelContext: ModelContext
    private var _chatNameTemp: String = ""
    
    var chats: [Chat] = []
    var activeChat: Chat? = nil
    var selectedChats = Set<Chat>()
    
    var isErrorWhenLoad = false
    var isRenameChatPresented = false
    var isDeleteConfirmationPresented = false
    
    var chatNameTemp: String {
        get {
            if isRenameChatPresented, let activeChat {
                return activeChat.name
            }
            
            return _chatNameTemp
        }
        
        set {
            _chatNameTemp = newValue
        }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func load() {
        do {
            let sortDescriptor = SortDescriptor(\Chat.modifiedAt, order: .reverse)
            let fetchDescriptor = FetchDescriptor<Chat>(sortBy: [sortDescriptor])
            
            self.chats = try self.modelContext.fetch(fetchDescriptor)
        } catch {
            self.isErrorWhenLoad = true
        }
    }
    
    func create(model: String) {
        let chat = Chat(model: model)
        
        self.modelContext.insert(chat)
        self.chats.insert(chat, at: 0)
    }
    
    func rename() {
        guard let activeChat else { return }
        
        if let index = self.chats.firstIndex(where: { $0.id == activeChat.id }) {
            self.chats[index].name = _chatNameTemp
            self.chats[index].modifiedAt = .now
        }
    }
    
    func remove() {
        for chat in selectedChats {
            self.modelContext.delete(chat)
            self.chats.removeAll(where: { $0.id == chat.id })
        }
    }
}
