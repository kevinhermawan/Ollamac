//
//  MessageCellView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 06/07/24.
//

import MarkdownUI
import SwiftUI
import ViewCondition
import ViewState

struct MessageCellView: View {
    private let content: String
    private var viewState: ViewState? = nil
    
    private var isAssistant: Bool = false
    private var isLastMessage: Bool = false
    private var regenerateAction: () -> Void = {}
    
    init(_ content: String) {
        self.content = content
        self.viewState = .none
    }
    
    init(_ content: String, viewState: ViewState?) {
        self.content = content
        self.viewState = viewState
    }
    
    @State private var isHovered: Bool = false
    
    private var title: String {
        isAssistant ? "Ollamac" : "You"
    }
    
    private var isCopyButtonVisible: Bool {
        isHovered && viewState != .loading
    }
    
    private var isRegenerateButtonVisible: Bool {
        isHovered && isLastMessage && viewState != .loading
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            MessageCellHeader(title)
            
            MessageCellContent(content, viewState: viewState)
                .lastMessage(isLastMessage)
            
            MessageCellFooter(copyAction: copyAction, regenerateAction: regenerateAction)
                .hovered(isHovered)
                .visibleCopyButton(isCopyButtonVisible)
                .visibleRegenerateButton(isRegenerateButtonVisible)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top)
        .onHover {
            isHovered = $0
        }
    }
    
    private func copyAction() {
        let markdown = MarkdownContent(content)
        let plainText = markdown.renderPlainText()
        
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.setString(plainText, forType: .string)
    }
    
    public func assistant(_ isAssistant: Bool) -> MessageCellView {
        var view = self
        view.isAssistant = isAssistant
        
        return view
    }
    
    public func lastMessage(_ isLastMessage: Bool) -> MessageCellView {
        var view = self
        view.isLastMessage = isLastMessage
        
        return view
    }
    
    public func regenerate(_ action: @escaping () -> Void) -> MessageCellView {
        var view = self
        view.regenerateAction = action
        
        return view
    }
}

#Preview {
    List {
        MessageCellView("The quick brown fox jumps over the lazy dog", viewState: .loading)
        
        MessageCellView("The quick brown fox jumps over the lazy dog")
        
        MessageCellView("The quick brown fox jumps over the lazy dog")
            .assistant(true)
        
        MessageCellView("The quick brown fox jumps over the lazy dog")
            .lastMessage(true)
        
        MessageCellView("The quick brown fox jumps over the lazy dog", viewState: .error(message: "Unexpected error"))
    }
}
