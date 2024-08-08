//
//  UpdateSystemPromptSheet.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/4/24.
//

import SwiftUI

struct UpdateSystemPromptSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var prompt: String
    
    private let action: (_ prompt: String) -> Void
    
    init(prompt: String, action: @escaping (_ prompt: String) -> Void) {
        self.prompt = prompt
        self.action = action
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                TextEditor(text: $prompt)
                    .textEditorStyle(.plain)
                    .scrollIndicators(.never)
                    .font(Font.system(size: 16))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 10)
            .frame(minWidth: 512, minHeight: 256)
            .navigationTitle("Update System Prompt")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: { dismiss() })
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        action(prompt)
                        dismiss()
                    }
                }
            }
        }
    }
}
