//
//  MessageViewModel.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import Alamofire
import SwiftData
import Foundation
import ViewState

@Observable
final class MessageViewModel {
    private var modelContext: ModelContext
    
    var fetchViewState: ViewState? = nil
    var generateViewState: ViewState? = nil
    
    var messages: [Message] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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
    func generate(_ message: Message) async {
        generateViewState = .loading
        
        messages.append(message)
        modelContext.insert(message)
        try? modelContext.saveChanges()
        
        let request = AF.streamRequest(OllamaAPI.generate(message: message), automaticallyCancelOnStreamError: true).validate()
        request.responseStreamDecodable(of: Message.self) { [weak self] stream in
            guard let strongSelf = self else { return }
            
            switch stream.event {
            case let .stream(result):
                switch result {
                case let .success(value):
                    strongSelf.setStreamSuccess(for: value)
                case .failure:
                    strongSelf.generateViewState = .error
                }
            case .complete:
                strongSelf.setStreamComplete()
            }
        }
    }
    
    private func setStreamSuccess(for message: Message) {
        if self.messages.isEmpty { return }
        
        let lastIndex = self.messages.count - 1
        let lastMessageResponse = self.messages[lastIndex].response ?? ""
        
        self.messages[lastIndex].context = message.context
        self.messages[lastIndex].response = lastMessageResponse + (message.response ?? "")
    }
    
    private func setStreamComplete() {
        do {
            try self.modelContext.saveChanges()
            self.generateViewState = nil
        } catch {
            self.generateViewState = .error
        }
    }
}
