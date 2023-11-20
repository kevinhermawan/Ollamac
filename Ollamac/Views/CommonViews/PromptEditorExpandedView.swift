//
//  PromptEditorExpandedView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 12/11/23.
//

import SwiftUI
import SwiftUIIntrospect

struct PromptEditorExpandedView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var prompt: String
    let sendAction: () -> Void
    
    private var sendButtonDisabled: Bool {
        if prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        
        return false
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                PromptEditor(prompt: $prompt, large: true)
            }
            .padding()
            .frame(minWidth: 768, minHeight: 512)
            .navigationTitle("Type a message...")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Dismiss")
                            .padding(8)
                    }
                    .keyboardShortcut("w", modifiers: .command)
                    .help("Dismiss editor (⌘ + W)")
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        sendAction()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            dismiss()
                        }
                    } label: {
                        Label("Send", systemImage: "paperplane")
                            .padding(8)
                    }
                    .disabled(sendButtonDisabled)
                    .buttonStyle(.borderedProminent)
                    .keyboardShortcut(.return, modifiers: [.shift, .command])
                    .help("Send message (⌘ + Shift + Return)")
                }
            }
        }
    }
}
