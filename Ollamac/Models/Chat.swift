//
//  Chat.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import Foundation
import SwiftData

@Model
final class Chat: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    
    var name: String
    var model: String
    var createdAt: Date = Date.now
    var modifiedAt: Date = Date.now
    
    @Relationship(deleteRule: .cascade, inverse: \Message.chat)
    var messages: [Message] = []
    
    init(name: String, model: String) {
        self.name = name
        self.model = model
    }
}
