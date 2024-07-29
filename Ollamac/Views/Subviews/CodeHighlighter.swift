//
//  CodeHighlighter.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 06/07/24.
//

import Highlightr
import MarkdownUI
import SwiftUI

@Observable
class CodeHighlighter: CodeSyntaxHighlighter {
    private let highlightr: Highlightr
    
    init() {
        guard let highlightrInstance = Highlightr() else {
            fatalError("Failed to initialize Highlightr")
        }
        
        self.highlightr = highlightrInstance
    }
    
    func highlightCode(_ code: String, language: String?) -> Text {
        let highlightedCode: NSAttributedString?

        if let language, !language.isEmpty {
            highlightedCode = highlightr.highlight(code, as: language)
        } else {
            highlightedCode = highlightr.highlight(code)
        }

        guard let highlightedCode else { return Text(code) }

        var attributedCode = AttributedString(highlightedCode)
        attributedCode.font = .system(size: 16, design: .monospaced)
        
        return Text(attributedCode)
    }

    func setTheme(to theme: String) {
        self.highlightr.setTheme(to: theme)
    }
}
