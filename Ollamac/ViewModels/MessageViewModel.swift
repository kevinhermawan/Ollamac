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
    
    var isErrorWhenLoad: Bool = false
    var isGenerating: Bool = false
    var generationErrorMessage: String? = nil
    
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
        
        do {
            self.messages = try self.modelContext.fetch(fetchDescriptor)
        } catch {
            self.isErrorWhenLoad = true
        }
    }
    
    func generate(activeChat: Chat, prompt: String) {
        let message = Message(prompt: prompt)
        message.chat = activeChat
        messages.append(message)
        modelContext.insert(message)
        
        let data = message.toOKChatRequestData(messages: messages)
        
        isGenerating = true
        generationErrorMessage = nil
        
        generationTask = Task {
            defer { isGenerating = false }
            
            do {
                for try await chunk in ollamaKit.chat(data: data) {
                    if Task.isCancelled { break }
                    
                    message.response = (message.response ?? "") + (chunk.message?.content ?? "")
                    
                    if chunk.done {
                        activeChat.modifiedAt = .now
                    }
                }
            } catch {
                generationErrorMessage = error.localizedDescription
            }
        }
    }
    
    
    func regenerate(activeChat: Chat) {
        guard let lastMessage = messages.last else { return }
        lastMessage.response = nil
        
        let data = lastMessage.toOKChatRequestData(messages: messages)
        
        isGenerating = true
        generationErrorMessage = nil
        
        generationTask = Task {
            defer { isGenerating = false }
            
            do {
                for try await chunk in ollamaKit.chat(data: data) {
                    if Task.isCancelled { break }
                    
                    lastMessage.response = (lastMessage.response ?? "") + (chunk.message?.content ?? "")
                    
                    if chunk.done {
                        activeChat.modifiedAt = .now
                    }
                }
            } catch {
                generationErrorMessage = error.localizedDescription
            }
        }
    }
    
    func cancelGeneration() {
        generationTask?.cancel()
        isGenerating = false
    }
}
