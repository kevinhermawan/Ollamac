//
//  CommandViewModel.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import CoreModels
import Foundation

@Observable
public final class CommandViewModel {
    public var isAddChatViewPresented: Bool = false
    public var isRenameChatViewPresented: Bool = false
    public var isDeleteChatConfirmationPresented: Bool = false
    
    public var selectedChat: Chat? = nil
    
    public init() {}
    
    public var chatToRename: Chat? {
        didSet {
            if chatToRename.isNotNil {
                isRenameChatViewPresented = true
            }
        }
    }
    
    public var chatToDelete: Chat? {
        didSet {
            if chatToDelete.isNotNil {
                isDeleteChatConfirmationPresented = true
            }
        }
    }
}
