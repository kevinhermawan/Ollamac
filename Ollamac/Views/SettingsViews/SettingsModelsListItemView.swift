//
//  SettingsModelsListItemView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 14/11/23.
//

import SwiftUI

struct SettingsModelsListItemView: View {
    private var model: OllamaModel
    private var duplicateAction: () -> Void
    private var deleteAction: () -> Void
    
    init(for model: OllamaModel, duplicateAction: @escaping () -> Void, deleteAction: @escaping () -> Void) {
        self.model = model
        self.duplicateAction = duplicateAction
        self.deleteAction = deleteAction
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.headline.weight(.medium))
                
                HStack {
                    Text(model.size.formattedByteCount)
                    
                    Divider()
                    
                    if model.isAvailable {
                        Text("Modified \(model.modifiedAt.relativeDateString)")
                    } else {
                        Text("Removed from the system")
                            .foregroundStyle(.red)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .help(model.digest)
            
            Spacer()
            
            HStack(spacing: 20) {
                Button(action: duplicateAction) {
                    Label("Duplicate model", systemImage: "doc.on.doc")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                }
                .buttonStyle(.borderless)
                .help("Duplicate model")
                
                Button(action: deleteAction) {
                    Label("Delete model", systemImage: "trash")
                        .labelStyle(.iconOnly)
                        .font(.title3)
                }
                .buttonStyle(.borderless)
                .disabled(model.isAvailable)
                .help("Delete model")
            }
        }
        .padding(.vertical, 8)
    }
}
