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
    private var generationTask: Task<Void, Never>?
    
    var messages: [Message] = []
    var loading: MessageViewModelLoading? = nil
    var error: MessageViewModelError? = nil
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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
    
    func generate(_ ollamaKit: OllamaKit, activeChat: Chat, prompt: String) {
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
                        
                        if messages.count == 1 {
                            self.generateTitle(ollamaKit, activeChat: activeChat)
                        }
                    }
                }
            } catch {
                self.error = .generate(error.localizedDescription)
            }
        }
    }
    
    func regenerate(_ ollamaKit: OllamaKit, activeChat: Chat) {
        guard let lastMessage = messages.last else { return }
        lastMessage.response = nil
        
        self.loading = .generate
        
        generationTask = Task {
            defer { self.loading = nil }
            
            do {
                for try await chunk in ollamaKit.chat(data: lastMessage.toOKChatRequestData(messages: messages)) {
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
    
    private func generateTitle(_ ollamaKit: OllamaKit, activeChat: Chat) {
        var requestMessages = [OKChatRequestData.Message]()
        
        for message in messages {
            let userMessage = OKChatRequestData.Message(role: .user, content: message.prompt)
            let assistantMessage = OKChatRequestData.Message(role: .assistant, content: message.response ?? "")
            
            requestMessages.append(userMessage)
            requestMessages.append(assistantMessage)
        }
        
        let userMessage = OKChatRequestData.Message(role: .user, content: "Just reply with a short title about this conversation.")
        requestMessages.append(userMessage)
        
        generationTask = Task {
            defer { self.loading = nil }
            
            do {
                for try await chunk in ollamaKit.chat(data: OKChatRequestData(model: activeChat.model, messages: requestMessages)) {
                    if Task.isCancelled { break }
                    
                    if activeChat.name == "New Chat" {
                        activeChat.name = ""
                        activeChat.name += chunk.message?.content ?? ""
                    } else {
                        activeChat.name += chunk.message?.content ?? ""
                    }
                    
                    if chunk.done {
                        activeChat.modifiedAt = .now
                    }
                }
            } catch {
                self.error = .generateTitle(error.localizedDescription)
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
    case generateTitle(String)
}
