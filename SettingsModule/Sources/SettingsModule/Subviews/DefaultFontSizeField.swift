//
//  DefaultFontSizeField.swift
//
//
//  Created by Philipp on 28.07.2024.
//

import SwiftUI

struct DefaultFontSizeField: View {

    @Binding var defaultFontSize: Double

    var range: ClosedRange<Double> = 8...100

    @State private var fontSize: Double = 16.0

    @ScaledMetric(relativeTo: .headline) private var width: CGFloat = 48

    private var systemFontSize: Int {
        Int(NSFont.systemFont(ofSize: 0).pointSize)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Font size")
                .font(.headline.weight(.semibold))


            HStack {
                TextField(String(systemFontSize), value: $fontSize, format: .number.precision(.fractionLength(0)))
                    .frame(width: width)
                    .textFieldStyle(.roundedBorder)
                Stepper("Font size", value: $fontSize, in: range)
                    .labelsHidden()
                Spacer()
            }
            .onChange(of: fontSize) { oldValue, newValue in
                if newValue > 7.9 && newValue < 100 {
                    defaultFontSize = newValue
                } else {
                    fontSize = defaultFontSize
                }
            }
        }
        .padding(4)
        .onAppear() {
            fontSize = defaultFontSize
        }
    }
}


#Preview("Default") {
    VStack {
        GroupBox {
            DefaultFontSizeField(defaultFontSize: .constant(16.0))
        }
    }
    .padding(16)
}
