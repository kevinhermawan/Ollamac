//
//  Chat.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Foundation
import SwiftData

@Model
final class Chat: Identifiable {
    @Attribute(.unique) var id: UUID
    
    var name: String
    var model: String
    var systemPrompt: String?
    var temperature: Double?
    var topP: Double?
    var topK: Int?
    
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    
    @Relationship(deleteRule: .cascade)
    var messages: [Message] = []
    
    init(model: String) {
        self.id = UUID()
        self.name = "New Chat"
        self.model = model
    }
}
