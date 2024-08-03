//
//  MessageViewModel.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import CoreModels
import Foundation
import OllamaKit
import SwiftData

@MainActor
@Observable
public final class MessageViewModel {
    private var generationTask: Task<Void, Never>?
    
    private var modelContext: ModelContext
    private var ollamaKit: OllamaKit
    
    public var messages: [Message] = []
    public var isErrorWhenLoad: Bool = false
    
    public var isGenerating: Bool = false
    public var generationErrorMessage: String? = nil
    
    public init(modelContext: ModelContext, ollamaKit: OllamaKit) {
        self.modelContext = modelContext
        self.ollamaKit = ollamaKit
    }
    
    public func load(of chat: Chat?) {
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
    
    public func generate(activeChat: Chat, prompt: String) {
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
    
    
    public func regenerate(activeChat: Chat) {
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
    
    public func cancelGeneration() {
        generationTask?.cancel()
        isGenerating = false
    }
}
