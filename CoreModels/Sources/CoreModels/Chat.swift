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
    @Attribute(.unique) public var id: UUID = UUID()
    
    public var name: String
    public var model: String
    public var createdAt: Date = Date.now
    public var modifiedAt: Date = Date.now
    
    @Relationship(deleteRule: .cascade, inverse: \Message.chat)
    public var messages: [Message] = []
    
    public init(name: String, model: String) {
        self.name = name
        self.model = model
    }
}
