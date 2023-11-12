//
//  ChatViewModel.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import SwiftData
import SwiftUI

@Observable
final class ChatViewModel {
    private var modelContext: ModelContext
        
    var chats: [Chat] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetch() throws {
        let sortDescriptor = SortDescriptor(\Chat.modifiedAt, order: .reverse)
        let fetchDescriptor = FetchDescriptor<Chat>(sortBy: [sortDescriptor])
        
        self.chats = try self.modelContext.fetch(fetchDescriptor)
    }
    
    func create(_ chat: Chat) throws {
        self.modelContext.insert(chat)
        self.chats.insert(chat, at: 0)
        
        try self.modelContext.saveChanges()
    }
    
    func rename(_ chat: Chat) throws {
        if let index = self.chats.firstIndex(where: { $0.id == chat.id }) {
            self.chats[index] = chat
        }
        
        try self.modelContext.saveChanges()
    }
    
    func delete(_ chat: Chat) throws {
        self.modelContext.delete(chat)
        self.chats.removeAll(where: { $0.id == chat.id })
        
        try self.modelContext.saveChanges()
    }
    
    func modify(_ chat: Chat) throws {
        chat.modifiedAt = .now

        if let index = self.chats.firstIndex(where: { $0.id == chat.id }) {
            self.chats.remove(at: index)
            self.chats.insert(chat, at: 0)
        }

        try self.modelContext.saveChanges()
    }
}
