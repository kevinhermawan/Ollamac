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
    private let images: [String]?
    private let copyAction: (_ content: String) -> Void
    
    init(content: String, images: [String]?, copyAction: @escaping (_ content: String) -> Void) {
        self.content = content
        self.images = images
        self.copyAction = copyAction
    }
    
    var body: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .trailing) {
                if let images = images, !images.isEmpty {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(images, id: \.self) { image in
                                if let convertedImage = decodeImage(from: image) {
                                    
                                    Image(nsImage: convertedImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(12)
                                }
                            }
                        }
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                    }
                }
                
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
    
    
    func decodeImage(from data: String) -> NSImage? {
        guard let imageData = Data(base64Encoded: data), let image = NSImage(data: imageData) else { return nil }
        
        return image
    }
}
