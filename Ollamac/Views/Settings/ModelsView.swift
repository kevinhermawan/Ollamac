//
//  ModelView.swift
//  Ollamac
//
//  Created by Haaris Iqubal on 4/13/25.
//

import Defaults
import SwiftUI
import OllamaKit

struct OKModelResponseItemView: Identifiable {
    
    var id = UUID()
    let modelName: String
    let modelSize: Int
    let modifiedDate: Date
}

struct OllamaModelList: Codable, Hashable, Identifiable {
    var id = UUID()
    let modelName: String
    let modelSize: String
    
    private enum CodingKeys: String, CodingKey {
            case modelName, modelSize
        }

    init(modelName: String, modelSize: String) {
        self.modelName = modelName
        self.modelSize = modelSize
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.modelName = try container.decode(String.self, forKey: .modelName)
        self.modelSize = try container.decode(String.self, forKey: .modelSize)
        self.id = UUID()
    }
}

struct ModelsView: View {
    @State private var isLoading = true
    @State private var models:[OKModelResponseItemView] = []
    @State private var modelList: [OllamaModelList] = []
    @State private var modelDownloadSelection: OllamaModelList? = nil
    @State private var ollamaKit: OllamaKit
    @State private var selection: OKModelResponseItemView.ID? = nil
    @State private var isAddModel  = false
    @State private var filterModelText = ""
    
    @State private var downloadProgress: Double? = nil
    @State private var downloadTotal: Int = 0
    @State private var downloadCompleted: Int = 0
    
    init() {
        let baseURL = URL(string: Defaults[.defaultHost])!
        self._ollamaKit = State(initialValue: OllamaKit(baseURL: baseURL))
    }
    
    var body: some View{
        
        content
            .onAppear {
                fetchModels(ollamaKit)
            }
    }
    
    // MARK: View
    
    private var content: some View {
        Group{
            VStack{
                if isLoading {
                    ProgressView()
                }
                else{
                    ModelsList
                }
                BottomBar
            }
            .sheet(isPresented: $isAddModel, content: {
                AddModelView()
            })
        }
        .frame(minHeight: 300)
    }
    
    
    private var ModelsList: some View {
        Table(of: OKModelResponseItemView.self, selection: $selection) {
            TableColumn("Name", value: \.modelName)
            TableColumn("Size") { model in
                Text(formatBytes(model.modelSize))
            }
            TableColumn("Modified") { model in
                Text(model.modifiedDate, format: .dateTime.year().month().day())
            }
        } rows : {
            ForEach(models) { model in
                TableRow(model)
                    .contextMenu {
                        Button("Delete") {
                            if let selection = selection {
                                // Delete button action
                                deleteModel(ollamaKit, models.first(where: { $0.id == selection })!)
                            }
                        }
                    }
            }
        }
    }
    
    private var BottomBar: some View {
        HStack {
            Button("Add", systemImage: "plus") {
                isAddModel.toggle()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            
            Button("Delete", systemImage: "minus") {
                if let selection = selection {
                    deleteModel(ollamaKit, models.first(where: { $0.id == selection })!)
                }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .disabled(models.isEmpty)
            .foregroundStyle(.primary)
            
            Spacer()
            
            Button("Refresh" , systemImage: "arrow.clockwise") {
                fetchModels(ollamaKit)
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .disabled(models.isEmpty)
            .foregroundStyle(.primary)
        }
    }
    
    private func AddModelView() -> some View {
        
        VStack(alignment: .leading){
            Text("Select model to download :")
            TextField("Search", text: $filterModelText)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom, 5)
            if let progress = downloadProgress {
                VStack(alignment: .leading) {
                        Text("Downloading: \(downloadCompleted) / \(downloadTotal) bytes")
                            .font(.caption)
                        ProgressView(value: progress)
                            .progressViewStyle(.linear)
                    }
                    .padding(.vertical, 10)
            }
            else{
                List(modelList.filter { filterModelText.isEmpty || $0.modelName.localizedCaseInsensitiveContains(filterModelText) }, id: \.modelName, selection: $modelDownloadSelection) { model in
                    HStack {
                        Text(model.modelName)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(model.modelSize)
                            .foregroundColor(.secondary)
                    }
                    .padding(3)
                    .contentShape(Rectangle())
                    .background(modelDownloadSelection == model ? Color.accentColor.opacity(0.9) : Color.clear)
                    .foregroundStyle(modelDownloadSelection == model ? .white : .primary)
                    .cornerRadius(4)
                    .onTapGesture {
                        modelDownloadSelection = model
                    }
                }
                .border(.secondary.opacity(0.3), width: 1)
                .scrollContentBackground(.hidden)
            }

            HStack{
                Spacer()
                Button("Cancel") {
                    isAddModel.toggle()
                }
                .foregroundStyle(.primary)
                .buttonStyle(.bordered)
                
                Button("Download") {
                    if let modelDownloadSelection = modelDownloadSelection {
                        downloadModel(ollamaKit, modelDownloadSelection)
                    }
                }
                .disabled(modelDownloadSelection == nil)
                .foregroundStyle(.primary)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(minHeight: 300)
        .onAppear{
            if let modelList = loadModelList() {
                self.modelList = modelList
            }
        }
        }
    
    // MARK: Interaction Functions
    
    func fetchModels(_ ollamaKit: OllamaKit) {
        
        Task {
            do {
                self.isLoading = true // Show loading indicator
                let isReachable = await ollamaKit.reachable()
                
                guard isReachable else {
                    print("Unable to connect to Ollama server. Please verify that Ollama is running and accessible.")
                    return
                }
                
                let response = try await ollamaKit.models()
                
                self.models = response.models.map {
                    OKModelResponseItemView(id: UUID(), modelName: $0.name, modelSize: $0.size, modifiedDate: $0.modifiedAt)
                }
                self.isLoading = false
                guard !self.models.isEmpty else {
                    print("You don't have any Ollama model. Please pull at least one Ollama model first.")
                    return
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteModel(_ ollamaKit: OllamaKit, _ model: OKModelResponseItemView) {
        Task {
            do {
                let isReachable = await ollamaKit.reachable()
                
                guard isReachable else {
                    print("Unable to connect to Ollama server. Please verify that Ollama is running and accessible.")
                    return
                }
                let modelRequest = OKDeleteModelRequestData(name: model.modelName)
                try await ollamaKit.deleteModel(data: modelRequest)
                
                // Remove the deleted model from the list
                self.models.removeAll { $0.id == model.id }
                fetchModels(ollamaKit)
            } catch {
                print("Error deleting model: \(error.localizedDescription)")
            }
        }
    }
    
    func downloadModel(_ ollamaKit: OllamaKit, _ model: OllamaModelList) {
        downloadProgress = 0 // start progress
        Task {
            do {
                let isReachable = await ollamaKit.reachable()
                
                guard isReachable else {
                    print("Unable to connect to Ollama server. Please verify that Ollama is running and accessible.")
                    return
                }
                let modelRequest = OKPullModelRequestData(model: model.modelName)
                
                for try await response in ollamaKit.pullModel(data: modelRequest) {
                    if let completed = response.completed, let total = response.total {
                        DispatchQueue.main.async {
                            self.downloadCompleted = completed
                            self.downloadTotal = total
                            self.downloadProgress = Double(completed) / Double(total)
                        }
                    }
                }
                // Reset after completion
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.downloadProgress = nil
                    self.isAddModel.toggle()
                    fetchModels(ollamaKit)
                }
            } catch {
                print("Error downloading model: \(error.localizedDescription)")
            }
        }
        }

    
    func loadModelList() -> [OllamaModelList]? {
        guard let url = Bundle.main.url(forResource: "LammaModelList", withExtension: "json") else {
            print("Failed to find models.json in bundle.")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let modelList = try JSONDecoder().decode([OllamaModelList].self, from: data)
            return modelList
        } catch {
            print("Error decoding model list: \(error)")
            return nil
        }
    }
    
    // MARK: Utility Functions
    
    func formatBytes(_ bytes: Int) -> String {
        let gb = Double(bytes) / 1_000_000_000 // 1 GB = 1000^3 bytes
        if gb >= 1 {
            return String(format: "%.2f GB", gb)
        } else {
            let mb = Double(bytes) / 1_000_000 // 1 MB = 1000^2 bytes
            return String(format: "%.2f MB", mb)
        }
    }
    
}



