//
//  PenOptionsSheet.swift
//  Spindigo
//
//  Created by Alan Metzger on 8/3/25.
//

import SwiftUI

struct PenOptionsSheet: View {
    @Binding var penSize: CGFloat
    @Binding var penColor: Color
    @Binding var canvasBackgroundColor: Color
    @Binding var isPresented: Bool

    // Bind selected quick pen color to current penColor
    private var selectedQuickPenColorBinding: Binding<QuickPenColor?> {
        Binding<QuickPenColor?>(
            get: {
                QuickPenColor.allCases.first(where: { $0.color == penColor })
            },
            set: { newValue in
                if let newColor = newValue?.color {
                    penColor = newColor
                }
            }
        )
    }

    // Bind selected quick background color to current canvasBackgroundColor
    private var selectedQuickBackgroundColorBinding: Binding<QuickBackgroundColor?> {
        Binding<QuickBackgroundColor?>(
            get: {
                QuickBackgroundColor.allCases.first(where: { $0.color == canvasBackgroundColor })
            },
            set: { newValue in
                if let newColor = newValue?.color {
                    canvasBackgroundColor = newColor
                }
            }
        )
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Pen Thickness")
                    .font(.title2).bold()
                    .foregroundStyle(.yellow)

                Text("\(Int(penSize))")
                    .font(.title).bold()

                Slider(value: $penSize, in: 1...30, step: 1)
                    .padding()

                Spacer()

                Text("Quick Pen Color")
                    .font(.title2).bold()
                    .foregroundStyle(.yellow)

                Picker("Quick Pen Color", selection: selectedQuickPenColorBinding) {
                    ForEach(QuickPenColor.allCases) { option in
                        Text(option.label).tag(Optional(option))
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ColorPicker("Precise Pen Color", selection: $penColor)
                    .padding()
                    .font(.title2)

                Spacer()

                Text("Quick Background Color")
                    .font(.title2).bold()
                    .foregroundStyle(.yellow)

                Picker("Quick Background Color", selection: selectedQuickBackgroundColorBinding) {
                    ForEach(QuickBackgroundColor.allCases) { option in
                        Text(option.label).tag(Optional(option))
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                ColorPicker("Precise Background Color", selection: $canvasBackgroundColor)
                    .padding()
                    .font(.title2)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                    }
                    .accessibilityLabel("Close")
                }
            }
        }
    }
}

