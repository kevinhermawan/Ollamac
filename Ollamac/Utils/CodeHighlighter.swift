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
    
    init() {
        guard let highlightrInstance = Highlightr() else {
            fatalError("Failed to initialize Highlightr")
        }
        
        self.highlightr = highlightrInstance
        self.highlightr.setTheme(to: "atom-one-dark")
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
        attributedCode.font = .system(size: 15, design: .monospaced)
        
        return Text(attributedCode)
    }
}

extension CodeSyntaxHighlighter where Self == CodeHighlighter {
    static var ollamac: Self {
        CodeHighlighter()
    }
}
