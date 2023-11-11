//
//  MessageViewModel.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import Foundation
import OllamaKit
import SwiftData
import ViewState

@Observable
final class MessageViewModel {
    private var modelContext: ModelContext
    private var ollamaKit: OllamaKit
    
    var messages: [Message] = []
    var sendViewState: ViewState? = nil
    
    init(modelContext: ModelContext, ollamaKit: OllamaKit) {
        self.modelContext = modelContext
        self.ollamaKit = ollamaKit
    }
    
    func fetch(for chat: Chat) throws {
        let chatId = chat.id
        let predicate = #Predicate<Message>{ $0.chat?.id == chatId }
        let sortDescriptor = SortDescriptor(\Message.createdAt)
        let fetchDescriptor = FetchDescriptor<Message>(predicate: predicate, sortBy: [sortDescriptor])
        
        messages = try modelContext.fetch(fetchDescriptor)
    }
    
    @MainActor
    func send(_ message: Message) async {
        self.sendViewState = .loading
        
        messages.append(message)
        modelContext.insert(message)
        try? modelContext.saveChanges()
        
        ollamaKit.generate(data: message.convertToOKGenerateRequestData()) { [weak self] stream in
            guard let strongSelf = self else { return }
            
            switch stream.event {
            case let .stream(result):
                switch result {
                case .success(let response):
                    strongSelf.write(response)
                    strongSelf.sendViewState = .loading
                case .failure:
                    strongSelf.sendViewState = .error
                    try? strongSelf.modelContext.saveChanges()
                }
            case .complete:
                try? strongSelf.modelContext.saveChanges()
                strongSelf.sendViewState = nil
            }
        }
    }
    
    func revertSend(_ message: Message) {
        messages.removeLast()
        modelContext.delete(message)
        
        try? modelContext.saveChanges()
    }
    
    private func write(_ response: OKGenerateResponse) {
        if self.messages.isEmpty { return }
        
        let lastIndex = self.messages.count - 1
        let lastMessageResponse = self.messages[lastIndex].response ?? ""
        
        self.messages[lastIndex].context = response.context
        self.messages[lastIndex].response = lastMessageResponse + response.response
    }
}

