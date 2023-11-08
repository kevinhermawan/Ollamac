//
//  Message.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import Foundation
import OptionalKit
import SwiftData

@Model
final class Message: Codable {
    @Attribute(.unique) var id: UUID = UUID()
    
    var prompt: String?
    var response: String?
    var context: [Int]?
    var createdAt: Date? = Date.now
    
    @Relationship
    var chat: Chat?
    
    @Transient var model: String {
        chat?.model?.name ?? ""
    }
        
    init(prompt: String?, response: String?) {
        self.prompt = prompt
        self.response = response
    }
    
    // MARK: - Codable
    private enum DecodableCodingKeys: String, CodingKey {
        case response, context
    }
    
    private enum EncodableCodingKeys: String, CodingKey {
        case model, prompt, context, stream
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DecodableCodingKeys.self)
        response = try container.decodeIfPresent(String.self, forKey: .response)
        context = try container.decodeIfPresent([Int].self, forKey: .context)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EncodableCodingKeys.self)
        try container.encode(model, forKey: .model)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(context, forKey: .context)
        try container.encode(true, forKey: .stream)
    }
}
