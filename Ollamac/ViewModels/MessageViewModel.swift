//
//  MessageViewModel.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import OllamaKit
import SwiftData
import Foundation
import ViewState

@Observable
final class MessageViewModel {
    private var modelContext: ModelContext
    private var ollamaKit: OllamaKit
    
    var fetchViewState: ViewState? = nil
    var sendViewState: ViewState? = nil
    var messages: [Message] = []
    
    init(modelContext: ModelContext, ollamaKit: OllamaKit) {
        self.modelContext = modelContext
        self.ollamaKit = ollamaKit
    }
    
    func fetch(for chat: Chat) {
        fetchViewState = .loading
        
        let chatId = chat.id
        let predicate = #Predicate<Message>{ $0.chat?.id == chatId }
        let sortDescriptor = SortDescriptor(\Message.createdAt)
        let fetchDescriptor = FetchDescriptor<Message>(predicate: predicate, sortBy: [sortDescriptor])
        
        do {
            messages = try modelContext.fetch(fetchDescriptor)
            fetchViewState = messages.isEmpty ? .empty : nil
        } catch {
            fetchViewState = .error
        }
    }
    
    @MainActor
    func send(_ message: Message) async {
        sendViewState = .loading
        
        messages.append(message)
        modelContext.insert(message)
        try? modelContext.saveChanges()
        
        ollamaKit.generate(data: message.convertToOKGenerateRequestData()) { [weak self] stream in
            guard let strongSelf = self else { return }
            
            switch stream.event {
            case let .stream(result):
                switch result {
                case let .success(value):
                    strongSelf.setStreamSuccess(for: value)
                case .failure:
                    strongSelf.sendViewState = .error
                }
            case .complete:
                strongSelf.setStreamComplete()
            }
        }
    }
    
    private func setStreamSuccess(for response: OKGenerateResponse) {
        if self.messages.isEmpty { return }
        
        let lastIndex = self.messages.count - 1
        let lastMessageResponse = self.messages[lastIndex].response ?? ""
        
        self.messages[lastIndex].context = response.context
        self.messages[lastIndex].response = lastMessageResponse + response.response
    }
    
    private func setStreamComplete() {
        do {
            try self.modelContext.saveChanges()
            self.sendViewState = nil
        } catch {
            self.sendViewState = .error
        }
    }
}
