//
//  Message.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import OllamaKit
import Foundation
import SwiftData

@Model
final class Message: Identifiable {
    @Attribute(.unique) var id: UUID
    
    var prompt: String
    var response: String?
    var createdAt: Date
    
    @Relationship
    var chat: Chat?
    
    init(prompt: String) {
        self.id = UUID()
        self.prompt = prompt
        self.createdAt = Date.now
    }
    
    @Transient var model: String {
        self.chat?.model ?? ""
    }
}

extension Message {
    func toOKChatRequestData(messages: [Message]) -> OKChatRequestData {
        var requestMessages = [OKChatRequestData.Message]()
        
        for message in messages {
            let userMessage = OKChatRequestData.Message(role: .user, content: message.prompt)
            let assistantMessage = OKChatRequestData.Message(role: .assistant, content: message.response ?? "")
            
            requestMessages.append(userMessage)
            requestMessages.append(assistantMessage)
        }
        
        if let systemPrompt = self.chat?.systemPrompt {
            let systemMessage = OKChatRequestData.Message(role: .system, content: systemPrompt)
            
            requestMessages.insert(systemMessage, at: 0)
        }
        
        var data = OKChatRequestData(model: self.model, messages: requestMessages)
        data.options?.temperature = self.chat?.temperature
        data.options?.topP = self.chat?.topP
        data.options?.topK = self.chat?.topK
        
        return data
    }
}
