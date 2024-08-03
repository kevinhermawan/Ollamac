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
public final class Message: Identifiable {
    @Attribute(.unique) public var id: UUID
    
    public var prompt: String
    public var response: String?
    public var createdAt: Date
    
    @Relationship
    public var chat: Chat?
    
    public init(prompt: String) {
        self.id = UUID()
        self.prompt = prompt
        self.createdAt = Date.now
    }
    
    @Transient var model: String {
        self.chat?.model ?? ""
    }
}

public extension Message {
    func toOKChatRequestData(messages: [Message]) -> OKChatRequestData {
        let messages = messages.flatMap { message in
            return [
                OKChatRequestData.Message(role: .user, content: message.prompt),
                OKChatRequestData.Message(role: .assistant, content: message.response ?? "")
            ]
        }
        
        let data = OKChatRequestData(model: self.model, messages: messages)
        
        return data
    }
}
