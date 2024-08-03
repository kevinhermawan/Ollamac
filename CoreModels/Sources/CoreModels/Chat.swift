//
//  Chat.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Foundation
import SwiftData

@Model
public final class Chat: Identifiable {
    @Attribute(.unique) public var id: UUID
    
    public var name: String
    public var model: String
    public var createdAt: Date = Date.now
    public var modifiedAt: Date = Date.now
    
    @Relationship(deleteRule: .cascade)
    public var messages: [Message] = []
    
    public init(model: String) {
        self.id = UUID()
        self.name = "New Chat"
        self.model = model
    }
}
