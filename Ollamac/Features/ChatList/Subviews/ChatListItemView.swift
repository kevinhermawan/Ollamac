//
//  ChatListItemView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 12/03/25.
//

import SwiftUI
import ViewCondition

struct ChatListItemView: View {
    @Bindable private var chat: Chat
    private var isSelected: Bool
    private var isEditing: Bool
    private var onBeginEditing: () -> Void
    private var onEndEditing: () -> Void
    
    @FocusState private var focused: Bool
    
    init(for chat: Chat, isSelected: Bool, isEditing: Bool, onBeginEditing: @escaping () -> Void, onEndEditing: @escaping () -> Void) {
        self.chat = chat
        self.isSelected = isSelected
        self.isEditing = isEditing
        self.onBeginEditing = onBeginEditing
        self.onEndEditing = onEndEditing
    }
    
    var body: some View {
        if isEditing {
            TextField("", text: $chat.name, onCommit: onEndEditing)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .textFieldStyle(.plain)
                .padding(4)
                .focused($focused)
                .onAppear {
                    focused = true
                }
        } else {
            Text(chat.name)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(4)
                .contentShape(Rectangle())
                .if(isSelected) { view in
                    view.onTapGesture(count: 2, perform: onBeginEditing)
                }
        }
    }
}
