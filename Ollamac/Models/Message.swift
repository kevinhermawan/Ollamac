//
//  Message.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import OllamaKit
import Foundation
import OptionalKit
import SwiftData

@Model
final class Message: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    
    var prompt: String?
    var response: String?
    var context: [Int]?
    var done: Bool = false
    var error: Bool = false
    var createdAt: Date = Date.now
    
    @Relationship var chat: Chat?
        
    init(prompt: String?, response: String?) {
        self.prompt = prompt
        self.response = response
    }
    
    @Transient var model: String {
        chat?.model?.name ?? ""
    }
}

extension Message {
    func convertToOKGenerateRequestData() -> OKGenerateRequestData {
        var data = OKGenerateRequestData(model: self.model, prompt: self.prompt ?? "")
        data.context = self.context
        
        return data
    }
}
