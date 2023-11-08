//
//  AppModel.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import SwiftData

struct AppModel {
    static let all: [any PersistentModel.Type] = [Chat.self, Message.self, OllamaModel.self]
}
