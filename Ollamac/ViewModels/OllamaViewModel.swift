//
//  OllamaViewModel.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import Alamofire
import OptionalKit
import SwiftData
import SwiftUI
import ViewState

@Observable
final class OllamaViewModel {
    private var modelContext: ModelContext
    
    var checkConnectionViewState: ViewState?
    var fetchViewState: ViewState?

    var models: [OllamaModel] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    @MainActor
    func checkConnection() async {
        self.checkConnectionViewState = .loading
        
        let request = AF.request(OllamaAPI.root).validate()
        
        do {
            let _ = try await request.serializingString().value
            
            self.checkConnectionViewState = nil
        } catch {
            self.checkConnectionViewState = .error
        }
    }
    
    @MainActor
    func fetch() async {
        self.fetchViewState = .loading
        
        let request = AF.request(OllamaAPI.models).validate()
        let response = request.serializingDecodable(OllamaModelResponse.self)
        
        do {
            let prevModels = try self.fetchModels()
            let newModels = try await response.value.models
            
            for model in prevModels {
                if newModels.contains(where: { $0.name == model.name }) {                    
                    model.isAvailable = true
                } else {
                    model.isAvailable = false
                }
            }
            
            for model in newModels {
                model.isAvailable = true
                self.modelContext.insert(model)
            }
            
            try self.modelContext.saveChanges()
            models = try self.fetchModels()
            
            self.fetchViewState = models.isEmpty ? .empty : nil
        } catch {
            self.fetchViewState = .error
        }
    }
    
    private func fetchModels() throws -> [OllamaModel] {
        let sortDescriptor = SortDescriptor(\OllamaModel.name)
        let fetchDescriptor = FetchDescriptor<OllamaModel>(sortBy: [sortDescriptor])
        
        return try modelContext.fetch(fetchDescriptor)
    }
    
    private struct OllamaModelResponse: Codable {
        var models: [OllamaModel]
    }
}
