//
//  MessageListItemView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import MarkdownUI
import SwiftUI
import ViewCondition

struct MessageListItemView: View {
    let text: String
    let isAssistant: Bool
    let isGenerating: Bool
    
    init(_ text: String, isAssistant: Bool, isGenerating: Bool = false) {
        self.text = text
        self.isAssistant = isAssistant
        self.isGenerating = isGenerating
    }
    
    @State private var isHovered: Bool = false
    @State private var isCopied: Bool = false
    
    var isCopyButtonVisible: Bool {
        isHovered && isAssistant && !isGenerating
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(isAssistant ? "Assistant" : "You")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.accent)
                
                Spacer()
                
                Button(action: copy) {
                    Label(
                        isCopied ? "Copied" : "Copy",
                        systemImage: isCopied ? "list.clipboard" : "clipboard"
                    )
                    .foregroundStyle(.accent)
                }
                .buttonStyle(.borderless)
                .visible(if: isCopyButtonVisible)
            }
            
            if isGenerating {
                ProgressView()
                    .controlSize(.small)
            } else {
                Markdown(text)
                    .textSelection(.enabled)
                    .markdownTextStyle(\.text) {
                        FontSize(NSFont.preferredFont(forTextStyle: .title3).pointSize)
                    }
                    .markdownTextStyle(\.code) {
                        FontFamily(.system(.monospaced))
                    }
                    .markdownBlockStyle(\.codeBlock) { configuration in
                        configuration
                            .label
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .markdownTextStyle {
                                FontSize(NSFont.preferredFont(forTextStyle: .title3).pointSize)
                                FontFamily(.system(.monospaced))
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(nsColor: .separatorColor))
                            }
                            .padding(.bottom)
                    }
            }
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onHover {
            isHovered = $0
            isCopied = false
        }
    }
    
    func copy() {
        let content = MarkdownContent(text)
        let plainText = content.renderPlainText()
        
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(plainText, forType: .string)
        
        isCopied = true
    }
}

#Preview {
    List {
        MessageListItemView("Hello, world!", isAssistant: false)
        MessageListItemView("Hello, world!", isAssistant: true)
        MessageListItemView("Hello, world!", isAssistant: true, isGenerating: true)
    }
}
