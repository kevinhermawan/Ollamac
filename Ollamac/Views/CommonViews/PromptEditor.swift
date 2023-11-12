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
    
    var body: some View {
        TextEditor(text: $prompt)
            .introspect(.textEditor, on: .macOS(.v14)) { textView in
                textView.enclosingScrollView?.hasVerticalScroller = false
                textView.enclosingScrollView?.hasHorizontalScroller = false
                textView.backgroundColor = .clear
            }
            .padding(8)
            .lineSpacing(8)
            .font(.title3.weight(.regular))
            .background(Color(nsColor: .textBackgroundColor))
            .clipShape(
                RoundedRectangle(cornerRadius: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(nsColor: .separatorColor))
            )
    }
}

#Preview {
    PromptEditor(prompt: .constant(""))
}
