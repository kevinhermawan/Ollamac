//
//  ChatViewModel.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import CoreExtensions
import CoreModels
import SwiftData
import SwiftUI

@Observable
public final class ChatViewModel {
    private var modelContext: ModelContext
    
    public var chats: [Chat] = []
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func fetch() throws {
        let sortDescriptor = SortDescriptor(\Chat.modifiedAt, order: .reverse)
        let fetchDescriptor = FetchDescriptor<Chat>(sortBy: [sortDescriptor])
        
        self.chats = try self.modelContext.fetch(fetchDescriptor)
    }
    
    public func create(_ chat: Chat) throws {
        self.modelContext.insert(chat)
        self.chats.insert(chat, at: 0)
        
        try self.modelContext.saveChanges()
    }
    
    public func rename(_ chat: Chat) throws {
        if let index = self.chats.firstIndex(where: { $0.id == chat.id }) {
            self.chats[index] = chat
        }
        
        try self.modelContext.saveChanges()
    }
    
    public func delete(_ chat: Chat) throws {
        self.modelContext.delete(chat)
        self.chats.removeAll(where: { $0.id == chat.id })
        
        try self.modelContext.saveChanges()
    }
    
    public func modify(_ chat: Chat) throws {
        chat.modifiedAt = .now
        
        if let index = self.chats.firstIndex(where: { $0.id == chat.id }) {
            self.chats.remove(at: index)
            self.chats.insert(chat, at: 0)
        }
        
        try self.modelContext.saveChanges()
    }
}
