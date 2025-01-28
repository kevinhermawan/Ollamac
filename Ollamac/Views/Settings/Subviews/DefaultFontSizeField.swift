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
        Text("Font size")
            .font(.headline.weight(.semibold))

        HStack {
            HStack {
                TextField(String(Default(.fontSize).defaultValue), value: $fontSize, format: .number.precision(.fractionLength(0)))
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: width)

                Stepper("Font size", value: $fontSize, in: range, step: 1)
            }
            .labelsHidden()
            .onChange(of: fontSize, { oldValue, newValue in
                if newValue < range.lowerBound {
                    fontSize = range.lowerBound
                } else if newValue > range.upperBound {
                    fontSize = range.upperBound
                }
            })

            Spacer()

            Button("Reset") {
                Default(.fontSize).reset()
            }
        }
    }
}


#Preview("Default") {
    VStack {
        GroupBox {
            DefaultFontSizeField()
        }

        Section {
            Box {
                DefaultFontSizeField()
            }
        }
    }
    .padding(16)
}
