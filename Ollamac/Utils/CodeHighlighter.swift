//
//  CodeHighlighter.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 06/07/24.
//

import Defaults
import Highlightr
import MarkdownUI
import SwiftUI

@Observable
class CodeHighlighter: CodeSyntaxHighlighter {
    private let highlightr: Highlightr
    var fontSize: Double {
        didSet {
            recalcState()
        }
    }
    var enabled: Bool {
        didSet {
            recalcState()
        }
    }
    var colorScheme: ColorScheme = .dark {
        didSet {
            recalcState()
        }
    }
    private(set) var stateHashValue: Int = 0

    init(colorScheme: ColorScheme, fontSize: Double, enabled: Bool) {
        guard let highlightrInstance = Highlightr() else {
            fatalError("Failed to initialize Highlightr")
        }
        self.highlightr = highlightrInstance
        self.highlightr.setTheme(to: "atom-one-dark")
        self.fontSize = fontSize
        self.colorScheme = colorScheme
        self.enabled = enabled

        recalcState()
    }

    func highlightCode(_ code: String, language: String?) -> Text {
        guard enabled else {
            return Text(code)
        }

        let highlightedCode: NSAttributedString?

        if let language, !language.isEmpty {
            highlightedCode = highlightr.highlight(code, as: language)
        } else {
            highlightedCode = highlightr.highlight(code)
        }

        guard let highlightedCode else { return Text(code) }

        var attributedCode = AttributedString(highlightedCode)
        attributedCode.font = .system(size: fontSize, design: .monospaced)

        return Text(attributedCode)
    }

    func set(colorScheme: ColorScheme, fontSize: Double, enabled: Bool) {
        let newTheme = colorScheme == .dark ? "atom-one-dark" : "atom-one-light"
        self.highlightr.setTheme(to: newTheme)
        self.colorScheme = colorScheme
        self.fontSize = fontSize
        recalcState()
    }

    private func recalcState() {
        var hasher = Hasher()
        hasher.combine(fontSize)
        hasher.combine(colorScheme)
        hasher.combine(enabled)
        stateHashValue = hasher.finalize()
    }
}
