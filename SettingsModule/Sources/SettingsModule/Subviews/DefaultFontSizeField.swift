//
//  DefaultFontSizeField.swift
//
//
//  Created by Philipp on 28.07.2024.
//

import Defaults
import SwiftUI

struct DefaultFontSizeField: View {

    @Default(.fontSize) private var fontSize

    var range: ClosedRange<Double> = 8...100

    @ScaledMetric(relativeTo: .headline) private var width: CGFloat = 48

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Font size")
                .font(.headline.weight(.semibold))

            HStack {
                TextField(String(Default(.fontSize).defaultValue), value: $fontSize, format: .number.precision(.fractionLength(0)))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: width)

                Stepper("Font size", value: $fontSize, in: range, step: 1)
                    .labelsHidden()

                Spacer()
            }
            .onChange(of: fontSize, { oldValue, newValue in
                if newValue < range.lowerBound {
                    fontSize = range.lowerBound
                } else if newValue > range.upperBound {
                    fontSize = range.upperBound
                }
            })

            Button("Reset") {
                Default(.fontSize).reset()
            }
        }
        .padding(4)
    }
}


#Preview("Default") {
    VStack {
        GroupBox {
            DefaultFontSizeField()
        }
    }
    .padding(16)
}
