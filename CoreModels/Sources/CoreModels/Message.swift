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
    @Attribute(.unique) public var id: UUID = UUID()
    
    public var prompt: String?
    public var response: String?
    public var context: [Int]?
    public var done: Bool = false
    public var createdAt: Date = Date.now
    
    @Relationship
    public var chat: Chat?
    
    public init(prompt: String?, response: String?) {
        self.prompt = prompt
        self.response = response
    }
    
    @Transient var model: String {
        chat?.model ?? ""
    }
}

public extension Message {
    func convertToOKGenerateRequestData() -> OKGenerateRequestData {
        var data = OKGenerateRequestData(model: self.model, prompt: self.prompt ?? "")
        data.context = self.context
        
        return data
    }
}
