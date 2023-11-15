//
//  SettingsModelsView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 14/11/23.
//

import SwiftUI
import ViewState

struct SettingsModelsView: View {
    let ollamaViewModel: OllamaViewModel
    
    @State private var errorMessage: String? = nil
    @State private var fetchViewState: ViewState? = nil
    
    var body: some View {
        VStack {
            List(ollamaViewModel.models) { model in
                SettingsModelsListItemView(
                    for: model,
                    duplicateAction: duplicateAction,
                    deleteAction: deleteAction
                )
            }
            .listStyle(.inset)
            .when(fetchViewState, is: .loading) {
                ProgressView()
                    .controlSize(.small)
            }
            .when(fetchViewState, is: .empty) {
                ContentUnavailableView {
                    Text(AppMessages.modelEmptyTitle)
                } description: {
                    Text(AppMessages.modelEmptyMessage)
                } actions: {
                    Button("Refresh", action: fetchAction)
                }
            }
            .when(fetchViewState, is: .error) {
                ContentUnavailableView {
                    Text("Failed to fetch models")
                } description: {
                    Text(errorMessage ?? "")
                } actions: {
                    Button("Try Again", action: fetchAction)
                }
            }
        }
        .task { fetchAction() }
    }
    
    // MARK: - Actions
    func fetchAction() {
        fetchViewState = .loading
        
        Task {
            do {
                if await ollamaViewModel.isReachable() {
                    try await ollamaViewModel.fetch()
                    fetchViewState = ollamaViewModel.models.isEmpty ? .empty : nil
                } else {
                    errorMessage = AppMessages.ollamaServerUnreachable
                    fetchViewState = .error
                }
            } catch {
                errorMessage = AppMessages.ollamaModelUnavailable
                fetchViewState = .error
            }
        }
    }
    
    func duplicateAction() {
        // TODO
    }
    
    func deleteAction() {
        // TODO
    }
}
