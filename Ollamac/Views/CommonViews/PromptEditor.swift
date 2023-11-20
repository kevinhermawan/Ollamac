//
//  PromptEditor.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 12/11/23.
//

import SwiftUI
import SwiftUIIntrospect

struct PromptEditor: View {
    @Binding var prompt: String
    let large: Bool
    
    var body: some View {
        if large {
            TextEditor(text: $prompt)
                .introspect(.textEditor, on: .macOS(.v14)) { textView in
                    textView.enclosingScrollView?.hasVerticalScroller = false
                    textView.enclosingScrollView?.hasHorizontalScroller = false
                    textView.backgroundColor = .clear
                }
                .padding(8)
                .modifier(PromptStyleModifier())
        } else {
            TextField("Type a message...", text: $prompt)
                .padding(8)
                .textFieldStyle(.plain)
                .modifier(PromptStyleModifier())
        }
    }
}

struct PromptStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .lineSpacing(8)
            .font(.title3.weight(.regular))
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .separatorColor))
            )
    }
}
