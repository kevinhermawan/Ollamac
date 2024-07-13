//
//  DefaultHostTextField.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import SwiftUI
import ViewState

struct DefaultHostTextField: View {
    @Binding private var defaultHost: String
    @Binding private var viewState: ViewState?
    private var saveAction: () -> Void
    
    public init(defaultHost: Binding<String>, viewState: Binding<ViewState?>, saveAction: @escaping () -> Void) {
        self._defaultHost = defaultHost
        self._viewState = viewState
        self.saveAction = saveAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Default Host")
                .font(.headline.weight(.semibold))
            
            TextField("http://localhost:11434", text: $defaultHost)
                .textFieldStyle(.roundedBorder)
            
            HStack {
                EmptyView()
                    .when(viewState, is: .loading) {
                        ProgressView()
                            .controlSize(.small)
                    }
                    .whenSuccess(viewState) { message in
                        Text(message)
                            .foregroundStyle(.green)
                    }
                    .whenError(viewState) { message in
                        Text(message)
                            .foregroundStyle(.red)
                    }
                
                Spacer()
                
                Button("Save", action: saveAction)
                    .disabled(viewState == .loading)
                    .disabled(defaultHost.isEmpty)
            }
        }
        .padding(4)
    }
}

#Preview("Default") {
    VStack {
        GroupBox {
            DefaultHostTextField(defaultHost: .constant("http://localhost:11434"), viewState: .constant(.none)) {
                
            }
        }
    }
    .padding(16)
}

#Preview("Empty") {
    VStack {
        GroupBox {
            DefaultHostTextField(defaultHost: .constant(""), viewState: .constant(.none)) {
                
            }
        }
    }
    .padding(16)
}

#Preview("Loading") {
    VStack {
        GroupBox {
            DefaultHostTextField(defaultHost: .constant("http://localhost:11434"), viewState: .constant(.loading)) {
                
            }
        }
    }
    .padding(16)
}

#Preview("Success") {
    VStack {
        GroupBox {
            DefaultHostTextField(defaultHost: .constant("http://localhost:11434"), viewState: .constant(.success(message: "Operation successful"))) {
                
            }
        }
    }
    .padding(16)
}

#Preview("Error") {
    VStack {
        GroupBox {
            DefaultHostTextField(defaultHost: .constant("http://localhost:11434"), viewState: .constant(.error(message: "An error occurred"))) {
                
            }
        }
    }
    .padding(16)
}
