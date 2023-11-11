//
//  Constants.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 06/11/23.
//

import Foundation

struct Constants {
    static let deleteChatConfirmationTitle = "Are you sure you want to delete this chat?"
    static let deleteChatConfirmationMessage = "All messages in this conversation will be permanently removed."
    
    static let ollamaConnectionErrorMessage = "It looks like the Ollama service is not currently running on your system."
    static let modelNotAvailableErrorMessage = "This model is currently unavailable or has been removed from the system."
    
    static let ollamaServerUnreachable = "The Ollama server cannot be reached at the moment."
    static let ollamaModelUnavailable = "This model is currently unavailable or has been removed."
    static let generalErrorMessage = "An error occurred. Please try again later."
}
