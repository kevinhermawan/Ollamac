//
//  ExperimentalView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/10/24.
//

import Defaults
import SwiftUI

struct ExperimentalView: View {
    @Default(.experimentalCodeHighlighting) private var experimentalCodeHighlighting
    
    var body: some View {
        Form {
            Section {
                Box {
                    HStack(alignment: .center) {
                        Text("Code Highlighting")
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Toggle("", isOn: $experimentalCodeHighlighting)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }
                }
            } footer: {
                SectionFooter("Enabling this might affect generation and scrolling performance.")
            }
        }
    }
}
