//
//  ChatViewModel.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import CoreModels
import SwiftData
import SwiftUI

@Observable
public final class ChatViewModel {
    private var modelContext: ModelContext
    
    public var chats: [Chat] = []
    public var activeChat: Chat? = nil
    public var selectedChats = Set<Chat>()
    
    public var isErrorWhenLoad = false
    public var isRenameChatPresented = false
    public var isDeleteConfirmationPresented = false
    
    private var _chatNameTemp: String = ""
    
    public var chatNameTemp: String {
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
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func load() {
        do {
            let sortDescriptor = SortDescriptor(\Chat.modifiedAt, order: .reverse)
            let fetchDescriptor = FetchDescriptor<Chat>(sortBy: [sortDescriptor])
            
            self.chats = try self.modelContext.fetch(fetchDescriptor)
        } catch {
            self.isErrorWhenLoad = true
        }
    }
    
    public func create(model: String) {
        let chat = Chat(model: model)
        
        self.modelContext.insert(chat)
        self.chats.insert(chat, at: 0)
    }
    
    public func rename() {
        guard let activeChat else { return }
        
        if let index = self.chats.firstIndex(where: { $0.id == activeChat.id }) {
            self.chats[index].name = _chatNameTemp
        }
    }
    
    public func remove() {
        for chat in selectedChats {
            self.modelContext.delete(chat)
            self.chats.removeAll(where: { $0.id == chat.id })
        }
    }
    
    public func modify() {
        guard let activeChat else { return }

        if let index = self.chats.firstIndex(where: { $0.id == activeChat.id }) {
            self.chats[index].modifiedAt = .now
        }
    }
}
