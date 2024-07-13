//
//  CommandViewModel.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 05/11/23.
//

import CoreModels
import Foundation

@Observable
final class CommandViewModel {
    var isAddChatViewPresented: Bool = false
    var isRenameChatViewPresented: Bool = false
    var isDeleteChatConfirmationPresented: Bool = false
    
    var selectedChat: Chat? = nil
    
    var chatToRename: Chat? {
        didSet {
            if chatToRename.isNotNil {
                isRenameChatViewPresented = true
            }
        }
    }
    
    var chatToDelete: Chat? {
        didSet {
            if chatToDelete.isNotNil {
                isDeleteChatConfirmationPresented = true
            }
        }
    }
}
