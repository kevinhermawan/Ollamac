//
//  UserMessageView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/2/24.
//

import Defaults
import SwiftUI
import ViewCondition

struct UserMessageView: View {
    @Default(.fontSize) private var fontSize

    private let windowWidth = NSApplication.shared.windows.first?.frame.width ?? 0
    private let content: String
    private let copyAction: (_ content: String) -> Void
    
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
                    .font(Font.system(size: fontSize))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                HStack(spacing: 16){
                    MessageButton("Copy", systemImage: "doc.on.doc", action: { copyAction(content) })
                }
            }
            .frame(maxWidth: windowWidth / 2, alignment: .trailing)
        }
    }
}
