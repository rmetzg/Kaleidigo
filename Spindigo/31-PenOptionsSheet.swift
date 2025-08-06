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
    @Binding var selectedQuickPenColor: QuickPenColor?
    @Binding var penEraser: Bool
    
    @Environment(\.dismiss) private var dismiss

    // Bind selected quick pen color to current penColor
    private var selectedQuickPenColorBinding: Binding<QuickPenColor?> {
        Binding<QuickPenColor?>(
            get: {
                if penEraser {
                    return .eraser
                } else {
                    return QuickPenColor.allCases.first(where: { $0.color == penColor })
                }
            },
            set: { newValue in
                if let newColor = newValue {
                    if newColor == .eraser {
                        penEraser = true
                    } else {
                        penEraser = false
                        penColor = newColor.color
                    }
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
        NavigationStack {
            VStack(spacing: DeviceInfo.isPhone ? 6 : 10) {
                Text("Pen / Eraser Thickness")
                    .font(.system(size: DeviceInfo.isPhone ? 16 : 22))
                    .bold()
                    .foregroundStyle(.yellow)

                Text("\(Int(penSize))")
                    .font(.system(size: DeviceInfo.isPhone ? 20 : 28))
                    .bold()
                    .foregroundStyle(.green)

                Slider(value: $penSize, in: 1...30, step: 1)
                    .padding(DeviceInfo.isPhone ? 8 : 16)


                Text("Quick Pen Color / Eraser")
                    .font(.system(size: DeviceInfo.isPhone ? 16 : 22))
                    .bold()
                    .foregroundStyle(.yellow)

                
                HStack {

                    if DeviceInfo.isPhone {
                        Picker("Quick Pen Color", selection: selectedQuickPenColorBinding) {
                            ForEach(QuickPenColor.allCases.filter { $0 != .eraser }) { option in
                                Text(option.label).tag(Optional(option))
                            }
                        }
                        .pickerStyle(.menu)
                        
                    } else {
                        Picker("Quick Pen Color", selection: selectedQuickPenColorBinding) {
                            ForEach(QuickPenColor.allCases.filter { $0 != .eraser }) { option in
                                Text(option.label).tag(Optional(option))
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Button(action: {
                        selectedQuickPenColor = .eraser
                        penEraser = true
                    }) {
                        Image("Eraser")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: DeviceInfo.isPhone ? 35 : 60, height: DeviceInfo.isPhone ? 35 : 60) // Adjust size as needed
                            .padding(DeviceInfo.isPhone ? 2 : 6)
                            .background(penEraser ? Color.gray.opacity(0.3) : Color.clear)
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Eraser Mode")
                }
                .padding(.horizontal, DeviceInfo.isPhone ? 2 : 16)
                
                ColorPicker("Precise Pen Color", selection: $penColor)
                    .font(.system(size: DeviceInfo.isPhone ? 16 : 22))
                    .padding(.bottom, 4)
                
                Spacer()

                Text("Quick Background Color")
                    .font(.system(size: DeviceInfo.isPhone ? 16 : 22))
                    .bold()
                    .foregroundStyle(.yellow)

                if DeviceInfo.isPhone {
                    Picker("Quick Background Color", selection: selectedQuickBackgroundColorBinding) {
                        ForEach(QuickBackgroundColor.allCases) { option in
                            Text(option.label).tag(Optional(option))
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                    .padding(.vertical, DeviceInfo.isPhone ? 6 : 16)
                } else {
                    Picker("Quick Background Color", selection: selectedQuickBackgroundColorBinding) {
                        ForEach(QuickBackgroundColor.allCases) { option in
                            Text(option.label).tag(Optional(option))
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.vertical, DeviceInfo.isPhone ? 6 : 16)
                }
                    

                ColorPicker("Precise Background Color", selection: $canvasBackgroundColor)
                    .padding(.bottom, 4)
                    .font(.system(size: DeviceInfo.isPhone ? 16 : 22))
                    .disabled(selectedQuickPenColor == .eraser)

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .cancellationAction) {
//                    Button(action: {
//                        dismiss()
//                    }) {
//                        Image(systemName: "xmark")
//                            .font(.system(size: DeviceInfo.isPhone ? 12 : 17))
//                    }
//                    .accessibilityLabel("Close")
//                }
//            }
        }
        .navigationTitle("Color Options")
        .navigationBarTitleDisplayMode(.inline)
    }
}

