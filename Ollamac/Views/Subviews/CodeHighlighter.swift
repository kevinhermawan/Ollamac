//
//  CodeHighlighter.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 06/07/24.
//

import Highlightr
import MarkdownUI
import SwiftUI

struct CodeHighlighter: CodeSyntaxHighlighter {
    private let highlightr: Highlightr
    
    init(theme: String) {
        guard let highlightrInstance = Highlightr() else {
            fatalError("Failed to initialize Highlightr")
        }
        
        self.highlightr = highlightrInstance
        self.highlightr.setTheme(to: theme)
    }
    
    func highlightCode(_ code: String, language: String?) -> Text {
        guard let highlightedCode = highlightr.highlight(code, as: language) else {
            return Text(code)
        }
        
        var attributedCode = AttributedString(highlightedCode)
        attributedCode.font = .system(size: 16, design: .monospaced)
        
        return Text(attributedCode)
    }
}

extension CodeSyntaxHighlighter where Self == CodeHighlighter {
    static func codeHighlighter(theme: String) -> Self {
        CodeHighlighter(theme: theme)
    }
}
