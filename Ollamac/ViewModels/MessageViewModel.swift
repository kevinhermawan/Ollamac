//
//  MessageViewModel.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Foundation
import OllamaKit
import SwiftData

@MainActor
@Observable
final class MessageViewModel {
    private var modelContext: ModelContext
    private var ollamaKit: OllamaKit
    private var generationTask: Task<Void, Never>?
    
    var messages: [Message] = []
    var loading: MessageViewModelLoading? = nil
    var error: MessageViewModelError? = nil
    
    init(modelContext: ModelContext, ollamaKit: OllamaKit) {
        self.modelContext = modelContext
        self.ollamaKit = ollamaKit
    }
    
    func load(of chat: Chat?) {
        guard let chat = chat else { return }
        
        let chatId = chat.id
        let predicate = #Predicate<Message> { $0.chat?.id == chatId }
        let sortDescriptor = SortDescriptor(\Message.createdAt)
        let fetchDescriptor = FetchDescriptor<Message>(predicate: predicate, sortBy: [sortDescriptor])
        
        self.loading = .load
        
        do {
            defer { self.loading = nil }
            self.messages = try self.modelContext.fetch(fetchDescriptor)
        } catch {
            self.error = .load(error.localizedDescription)
        }
    }
    
    func generate(activeChat: Chat, prompt: String) {
        let message = Message(prompt: prompt)
        message.chat = activeChat
        messages.append(message)
        modelContext.insert(message)
        
        let data = message.toOKChatRequestData(messages: messages)
        
        self.loading = .generate
        self.error = nil
        
        generationTask = Task {
            defer { self.loading = nil }
            
            do {
                for try await chunk in ollamaKit.chat(data: data) {
                    if Task.isCancelled { break }
                    
                    message.response = (message.response ?? "") + (chunk.message?.content ?? "")
                    
                    if chunk.done {
                        activeChat.modifiedAt = .now
                    }
                }
            } catch {
                self.error = .generate(error.localizedDescription)
            }
        }
    }
    
    
    func regenerate(activeChat: Chat) {
        guard let lastMessage = messages.last else { return }
        lastMessage.response = nil
        
        let data = lastMessage.toOKChatRequestData(messages: messages)
        
        self.loading = .generate
        self.error = nil
        
        generationTask = Task {
            defer { self.loading = nil }
            
            do {
                for try await chunk in ollamaKit.chat(data: data) {
                    if Task.isCancelled { break }
                    
                    lastMessage.response = (lastMessage.response ?? "") + (chunk.message?.content ?? "")
                    
                    if chunk.done {
                        activeChat.modifiedAt = .now
                    }
                }
            } catch {
                self.error = .generate(error.localizedDescription)
            }
        }
    }
    
    func cancelGeneration() {
        self.generationTask?.cancel()
        self.loading = .generate
    }
}

enum MessageViewModelLoading {
    case load
    case generate
}

enum MessageViewModelError: Error {
    case load(String)
    case generate(String)
}
