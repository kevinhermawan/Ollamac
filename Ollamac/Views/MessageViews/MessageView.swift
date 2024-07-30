//
//  MessageView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import CoreModels
import CoreViewModels
import SwiftUI

struct MessageView: View {
    @Environment(ChatViewModel.self) private var chatViewModel
    @Environment(MessageViewModel.self) private var messageViewModel

    let message: Message
    let isLastMessage: Bool
    var regenerateAction: () -> Void = {}

    var body: some View {
        MessageCellView(message.prompt ?? "")
            .assistant(false)

        MessageCellView(message.response ?? "", viewState: messageViewModel.sendViewState)
            .assistant(true)
            .lastMessage(isLastMessage)
            .regenerate(regenerateAction)
            .id(message.id)
    }
}
