//
//  PromptField.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 07/12/23.
//

import SwiftUI
import SwiftUIIntrospect

struct PromptField: View {
    @Binding var prompt: String
    let onSubmit: () -> Void
    
    var body: some View {
        TextField("Type a message...", text: $prompt, axis: .vertical)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .textFieldStyle(.plain)
            .font(.system(size: 14))
            .clipShape(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(nsColor: .lightGray))
            )
            .introspect(.textField(axis: .vertical), on: .macOS(.v14)) { textField in
                textField.lineBreakMode = .byWordWrapping
            }
            .onSubmit {
                if NSApp.currentEvent?.modifierFlags.contains(.shift) == true {
                    prompt.appendNewLine()
                } else {
                    onSubmit()
                }
            }
    }
}
