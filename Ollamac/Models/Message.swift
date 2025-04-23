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
    @Attribute(.unique) var id: UUID = UUID()
    
    var prompt: String
    var response: String?
    var createdAt: Date = Date.now
    
    @Attribute var imagesData: Data? // Store encoded images array
    
    @Relationship
    var chat: Chat?
    
    init(prompt: String) {
        self.prompt = prompt
    }
    
    @Transient var model: String {
        self.chat?.model ?? ""
    }

    var responseText: String {
        var response = self.response ?? ""

        // identify <think> phase of model and remove it
        if let start = response.ranges(of: "<think>").first?.lowerBound {
            if let end = response.ranges(of: "</think>").first?.upperBound {
                response.removeSubrange(start...end)
            }
        }

        // return trimmed text
        return response.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Computed property to get/set images as an array
        var images: [String]? {
            get {
                guard let data = imagesData else { return nil }
                return try? JSONDecoder().decode([String].self, from: data)
            }
            set {
                imagesData = try? JSONEncoder().encode(newValue)
            }
        }
}

extension Message {
    func toOKChatRequestData(messages: [Message], images: [String]?) -> OKChatRequestData {
        var requestMessages = [OKChatRequestData.Message]()
        
        for message in messages {
            let userMessage = OKChatRequestData.Message(role: .user, content: message.prompt, images: images)
            let assistantMessage = OKChatRequestData.Message(role: .assistant, content: message.response ?? "")
            
            requestMessages.append(userMessage)
            requestMessages.append(assistantMessage)
        }
        
        if let systemPrompt = self.chat?.systemPrompt {
            let systemMessage = OKChatRequestData.Message(role: .system, content: systemPrompt)
            
            requestMessages.insert(systemMessage, at: 0)
        }
        
        let options = OKCompletionOptions(
            temperature: self.chat?.temperature,
            topK: self.chat?.topK,
            topP: self.chat?.topP
        )
        
        var data = OKChatRequestData(model: self.model, messages: requestMessages)
        data.options = options
        
        return data
    }
}
