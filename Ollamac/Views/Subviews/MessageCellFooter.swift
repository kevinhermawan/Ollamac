//
//  MessageCellFooter.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 07/07/24.
//

import SwiftUI
import ViewCondition

struct MessageCellFooter: View {
    @State private var isCopied: Bool = false
    
    private var copyAction: () -> Void
    private var regenerateAction: () -> Void
    
    init(copyAction: @escaping () -> Void, regenerateAction: @escaping () -> Void) {
        self.copyAction = copyAction
        self.regenerateAction = regenerateAction
    }
    
    private var isHovered: Bool = false
    private var isCopyButtonVisible: Bool = false
    private var isRegenerateButtonVisible: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Button {
                copyAction()
                isCopied = true
            } label: {
                Image(systemName: isCopied ? "list.clipboard.fill" : "clipboard")
            }
            .buttonStyle(.accessoryBar)
            .clipShape(.circle)
            .visible(if: isCopyButtonVisible)
            
            Button(action: regenerateAction) {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
            .buttonStyle(.accessoryBar)
            .clipShape(.circle)
            .visible(if: isRegenerateButtonVisible)
        }
        .padding(.vertical, 8)
        .onChange(of: isHovered) {
            isCopied = false
        }
        .visible(if: isHovered)
    }
    
    public func hovered(_ isHovered: Bool) -> MessageCellFooter {
        var view = self
        view.isHovered = isHovered
        
        return view
    }
    
    public func visibleCopyButton(_ isVisible: Bool) -> MessageCellFooter {
        var view = self
        view.isCopyButtonVisible = isVisible
        
        return view
    }
    
    public func visibleRegenerateButton(_ isVisible: Bool) -> MessageCellFooter {
        var view = self
        view.isRegenerateButtonVisible = isVisible
        
        return view
    }
}

#Preview {
    List {
        MessageCellFooter(copyAction: {}, regenerateAction: {})
            .hovered(true)
            .visibleCopyButton(true)
        
        MessageCellFooter(copyAction: {}, regenerateAction: {})
            .hovered(true)
            .visibleCopyButton(true)
            .visibleRegenerateButton(true)
    }
}
