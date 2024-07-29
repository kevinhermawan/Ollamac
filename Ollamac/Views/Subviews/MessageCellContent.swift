//
//  MessageCellContent.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 06/07/24.
//

import MarkdownUI
import SwiftUI
import ViewState

struct MessageCellContent: View {
    private var isLastMessage: Bool = false
    
    private let content: String
    private let viewState: ViewState?
    
    init(_ content: String, viewState: ViewState?) {
        self.content = content
        self.viewState = viewState
    }
    
    private var generatingViewState: ViewState? {
        content.isEmpty && viewState == .loading ? .loading : nil
    }
    
    private var errorViewState: ViewState? {
        guard let errorMessage = viewState?.errorMessage else { return nil }
        
        return isLastMessage ? .error(message: errorMessage) : nil
    }
    
    var body: some View {
        Markdown(content)
            .textSelection(.enabled)
            .when(generatingViewState, is: .loading) {
                ProgressView()
                    .controlSize(.small)
            }
            .whenError(errorViewState) { message in
                Text(message)
                    .font(.system(size: 16))
                    .foregroundStyle(.red)
            }
    }
    
    public func lastMessage(_ isLastMessage: Bool) -> MessageCellContent {
        var view = self
        view.isLastMessage = isLastMessage
        
        return view
    }
}

#Preview {
    List {
        MessageCellContent("The quick brown fox jumps over the lazy dog", viewState: nil)
        MessageCellContent("The quick brown fox jumps over the lazy dog", viewState: .loading)
        MessageCellContent("The quick brown fox jumps over the lazy dog", viewState: .error(message: "Unexpected error"))
    }
}
