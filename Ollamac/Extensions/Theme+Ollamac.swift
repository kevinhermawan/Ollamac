//
//  Theme+Ollamac.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/3/24.
//

import Foundation
import MarkdownUI
import SwiftUI

class ThemeCache {
    static let shared = ThemeCache()
    private var cachedTheme: Theme?
    private var cachedCodeBlocks: [CodeBlockConfiguration: CodeBlockView] = [:]
    
    func getTheme() -> Theme {
        if let existingTheme = cachedTheme {
            return existingTheme
        } else {
            let newTheme = Theme()
                .paragraph { configuration in
                    configuration.label
                        .relativeLineSpacing(.em(0.25))
                }
                .code {
                    FontFamilyVariant(.monospaced)
                }
                .codeBlock { configuration in
                    CodeBlockView(configuration: configuration)
                }
                .listItem { configuration in
                    configuration.label
                        .markdownMargin(top: .em(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
            
            cachedTheme = newTheme
            
            return newTheme
        }
    }
    
//    private func getCodeBlockView(for configuration: CodeBlockConfiguration) -> CodeBlockView {
//        if let cachedView = cachedCodeBlocks[configuration] {
//            return cachedView
//        } else {
//            let newView = CodeBlockView(configuration: configuration)
//            cachedCodeBlocks[configuration] = newView
//            
//            return newView
//        }
//    }
}

extension Theme {
    static var ollamac: Theme {
        ThemeCache.shared.getTheme()
    }
}
