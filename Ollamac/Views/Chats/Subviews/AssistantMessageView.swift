//
//  AssistantMessageView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/2/24.
//

import MarkdownUI
import SwiftUI
import ViewCondition

struct AssistantMessageView: View {
    private let content: String?
    private let isGenerating: Bool
    private let isLastMessage: Bool
    private let copyAction: (_ content: String) -> Void
    private let regenerateAction: () -> Void
    
    init(content: String?, isGenerating: Bool, isLastMessage: Bool, copyAction: @escaping (_ content: String) -> Void, regenerateAction: @escaping () -> Void) {
        self.content = content
        self.isGenerating = isGenerating
        self.isLastMessage = isLastMessage
        self.copyAction = copyAction
        self.regenerateAction = regenerateAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Assistant")
                .font(Font.system(size: 16).weight(.semibold))
                .foregroundStyle(.accent)
            
            if let content {
                Markdown(content)
                    .textSelection(.enabled)
                    .markdownTheme(.ollamac)
                    .markdownCodeSyntaxHighlighter(.ollamac)
                
                HStack(spacing: 16) {
                    MessageButton("Copy", systemImage: "doc.on.doc", action: { copyAction(content) })
                    
                    MessageButton("Regenerate", systemImage: "arrow.triangle.2.circlepath", action: regenerateAction)
                        .keyboardShortcut("r", modifiers: [.command])
                        .visible(if: isLastMessage, removeCompletely: true)
                }
            } else if isGenerating {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
