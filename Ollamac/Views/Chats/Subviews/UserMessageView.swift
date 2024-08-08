//
//  UserMessageView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/2/24.
//

import SwiftUI
import ViewCondition

struct UserMessageView: View {
    private let windowWidth = NSApplication.shared.windows.first?.frame.width ?? 0
    private let content: String
    private let copyAction: (_ content: String) -> Void
    
    @State private var isCopied: Bool = false
    
    init(content: String, copyAction: @escaping (_ content: String) -> Void) {
        self.content = content
        self.copyAction = copyAction
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(content)
                    .padding(12)
                    .background(.accent)
                    .foregroundColor(.white)
                    .textSelection(.enabled)
                    .font(Font.system(size: 16))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                HStack(spacing: 16){
                    MessageButton(isCopied ? "Copied" : "Copy", systemImage: isCopied ? "checkmark" : "doc.on.doc", action: handleCopy)
                }
            }
            .frame(maxWidth: windowWidth / 2, alignment: .trailing)
        }
    }
    
    private func handleCopy() {
        self.copyAction(content)
        self.isCopied = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isCopied = false
        }
    }
}
