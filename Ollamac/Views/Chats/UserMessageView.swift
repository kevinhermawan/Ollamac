//
//  UserMessageView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/2/24.
//

import SwiftUI

struct UserMessageView: View {
    private let windowWidth = NSApplication.shared.windows.first?.frame.width ?? 0
    
    let content: String
    
    init(content: String) {
        self.content = content
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            Text(content)
                .padding(12)
                .background(.accent)
                .foregroundColor(.white)
                .textSelection(.enabled)
                .font(Font.system(size: 16))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(maxWidth: windowWidth / 2, alignment: .trailing)
        }
    }
}
