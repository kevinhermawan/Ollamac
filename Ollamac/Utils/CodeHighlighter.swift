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

class CodeHighlighterCache {
    static let shared = CodeHighlighterCache()
    private var highlighter: CodeHighlighter?
    
    private init() {}
    
    func getHighlighter() -> CodeHighlighter {
        if let existingHighlighter = highlighter {
            return existingHighlighter
        } else {
            let newHighlighter = CodeHighlighter()
            highlighter = newHighlighter
            
            return newHighlighter
        }
    }
}

extension CodeSyntaxHighlighter where Self == CodeHighlighter {
    static var ollamac: Self {
        CodeHighlighterCache.shared.getHighlighter()
    }
}
