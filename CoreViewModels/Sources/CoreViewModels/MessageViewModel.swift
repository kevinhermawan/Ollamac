//
//  MessageViewModel.swift
//  
//
//  Created by Kevin Hermawan on 13/07/24.
//

import CoreExtensions
import CoreModels
import Combine
import Foundation
import OllamaKit
import SwiftData
import ViewState

@Observable
public final class MessageViewModel {
    private var generation: AnyCancellable?
    
    private var modelContext: ModelContext
    private var ollamaKit: OllamaKit
    
    public var messages: [Message] = []
    public var sendViewState: ViewState? = nil
    
    public init(modelContext: ModelContext, ollamaKit: OllamaKit) {
        self.modelContext = modelContext
        self.ollamaKit = ollamaKit
    }
    
    deinit {
        self.stopGenerate()
    }
    
    public func fetch(for chat: Chat) throws {
        let chatId = chat.id
        let predicate = #Predicate<Message>{ $0.chat?.id == chatId }
        let sortDescriptor = SortDescriptor(\Message.createdAt)
        let fetchDescriptor = FetchDescriptor<Message>(predicate: predicate, sortBy: [sortDescriptor])
        
        messages = try modelContext.fetch(fetchDescriptor)
    }
    
    @MainActor
    public func send(_ message: Message) async {
        self.sendViewState = .loading
        
        messages.append(message)
        modelContext.insert(message)
        try? modelContext.saveChanges()
        
        if await ollamaKit.reachable() {
            let data = message.convertToOKGenerateRequestData()
            
            generation = ollamaKit.generate(data: data)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.handleComplete()
                    case .failure(let error):
                        self?.handleError(error.localizedDescription)
                    }
                }, receiveValue: { [weak self] response in
                    self?.handleReceive(response)
                })
        } else {
            self.handleError(AppMessages.ollamaServerUnreachable)
        }
    }
    
    @MainActor
    public func regenerate(_ message: Message) async {
        self.sendViewState = .loading
        
        messages[messages.endIndex - 1] = message
        try? modelContext.saveChanges()
        
        if await ollamaKit.reachable() {
            let data = message.convertToOKGenerateRequestData()
            
            generation = ollamaKit.generate(data: data)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        self?.handleComplete()
                    case .failure(let error):
                        self?.handleError(error.localizedDescription)
                    }
                }, receiveValue: { [weak self] response in
                    self?.handleReceive(response)
                })
        } else {
            self.handleError(AppMessages.ollamaServerUnreachable)
        }
    }
    
    public func stopGenerate() {
        self.sendViewState = nil
        self.generation?.cancel()
        try? self.modelContext.saveChanges()
    }
    
    private func handleReceive(_ response: OKGenerateResponse) {
        if self.messages.isEmpty { return }
        
        let lastIndex = self.messages.count - 1
        let lastMessageResponse = self.messages[lastIndex].response ?? ""
        self.messages[lastIndex].context = response.context
        self.messages[lastIndex].response = lastMessageResponse + response.response
        
        self.sendViewState = .loading
    }
    
    private func handleError(_ errorMessage: String) {
        if self.messages.isEmpty { return }
        
        let lastIndex = self.messages.count - 1
        self.messages[lastIndex].done = false
        
        try? self.modelContext.saveChanges()
        self.sendViewState = .error(message: errorMessage)
    }
    
    private func handleComplete() {
        if self.messages.isEmpty { return }
        
        let lastIndex = self.messages.count - 1
        self.messages[lastIndex].done = true
        
        try? self.modelContext.saveChanges()
        self.sendViewState = nil
    }
}
