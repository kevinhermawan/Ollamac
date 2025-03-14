//
//  AppView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 03/11/23.
//

import Defaults
import MarkdownUI
import SwiftUI

struct AppView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(CodeHighlighter.self) private var codeHighlighter

    @AppStorage("experimentalCodeHighlighting") private var experimentalCodeHighlighting = false
    @Default(.fontSize) private var fontSize

    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 256, ideal: 256)
        } detail: {
            ChatView()
        }
        .markdownTextStyle(\.text) {
            FontSize(CGFloat(fontSize))
        }
        .markdownTextStyle(\.code) {
            FontSize(CGFloat(fontSize))
            FontFamily(.system(.monospaced))
        }
        .markdownTheme(.ollamac)
        .markdownCodeSyntaxHighlighter(experimentalCodeHighlighting ? codeHighlighter : .plainText)
        .onChange(of: colorScheme, initial: true) {
            codeHighlighter.colorScheme = colorScheme
        }
        .onChange(of: fontSize, initial: true) {
            codeHighlighter.fontSize = fontSize
        }
        .onChange(of: experimentalCodeHighlighting) {
            codeHighlighter.enabled = experimentalCodeHighlighting
        }
    }
}
