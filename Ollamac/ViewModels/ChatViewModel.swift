//
//  ChatViewModel.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import SwiftData
import SwiftUI
import ViewState

@Observable
final class ChatViewModel {
    private var modelContext: ModelContext
    
    var fetchViewState: ViewState?
    var renameViewState: ViewState?
    var deleteViewState: ViewState?
    
    var chats: [Chat] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetch() {
        self.fetchViewState = nil
        
        let sortDescriptor = SortDescriptor(\Chat.createdAt, order: .reverse)
        let fetchDescriptor = FetchDescriptor<Chat>(sortBy: [sortDescriptor])
        
        do {
            self.chats = try self.modelContext.fetch(fetchDescriptor)
            self.fetchViewState = self.chats.isEmpty ? .empty : nil
        } catch {
            self.fetchViewState = .error
        }
    }
    
    func create(_ chat: Chat) throws {
        self.modelContext.insert(chat)
        self.chats.insert(chat, at: 0)
        
        try self.modelContext.saveChanges()
    }
    
    func rename(_ chat: Chat) {
        self.renameViewState = .loading
        
        if let index = self.chats.firstIndex(where: { $0.id == chat.id }) {
            self.chats[index] = chat
        }
        
        do {
            try self.modelContext.saveChanges()
            self.renameViewState = nil
        } catch {
            self.renameViewState = .error
        }
    }
    
    func delete(_ chat: Chat) {
        self.deleteViewState = .loading
        
        self.modelContext.delete(chat)
        self.chats.removeAll(where: { $0.id == chat.id })
        
        do {
            try self.modelContext.saveChanges()
            self.deleteViewState = nil
        } catch {
            self.deleteViewState = .error
        }
    }
}
