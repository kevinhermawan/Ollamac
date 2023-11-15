//
//  OllamaModel.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 03/11/23.
//

import Foundation
import SwiftData

@Model
final class OllamaModel: Identifiable {
    @Attribute(.unique) var name: String
    var size: Int = 0
    var digest: String = ""
    var modifiedAt: Date = Date.now
    var isAvailable: Bool = false
    
    @Relationship(deleteRule: .cascade, inverse: \Chat.model)
    var chats: [Chat] = []
    
    init(name: String, size: Int, digest: String, modifiedAt: Date) {
        self.name = name
        self.size = size
        self.digest = digest
        self.modifiedAt = modifiedAt
    }
    
    @Transient var isNotAvailable: Bool {
        isAvailable == false
    }
}
