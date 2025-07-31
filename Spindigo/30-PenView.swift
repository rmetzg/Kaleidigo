//
//  PenView.swift
//  Spindigo
//
//  Created by Alan Metzger on 7/28/25.
//

import SwiftUI


struct PenView: View {
    @Binding var penSize: CGFloat
    @Binding var displayFrameRate: Int
    @Binding var spinRPM: Double
    @Binding var clearTrigger: Bool
    @Binding var isActive: Bool

    @State private var showClearAlert = false
    @State private var showPenOptionsSheet = false
    @State private var penColor: Color = .blue

    var body: some View {
        VStack(spacing: 0) {
            DrawingCanvasView(
                displayFrameRate: $displayFrameRate,
                spinRPM: $spinRPM,
                clearTrigger: $clearTrigger,
                penSize: $penSize,
                penColor: $penColor,
                isActive: $isActive
            )
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        // Trash (Clear) Button
                        Button {
                            showClearAlert = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 22))
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .accessibilityLabel("Clear canvas")

                        Spacer()

                        // Pen Options Button
                        Button {
                            showPenOptionsSheet = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.4))
                                    .frame(width: 54, height: 54)
                                    .shadow(radius: 5)

                                VStack(spacing: 3) {
                                    Rectangle().fill(Color.green).frame(width: 20, height: 4)
                                    Rectangle().fill(Color.blue).frame(width: 20, height: 6)
                                    Rectangle().fill(Color.red).frame(width: 20, height: 8)
                                }
                            }
                        }
                        .accessibilityLabel("Pen options")
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, -25)  // 👈 Lower them toward bottom here
                }
                .ignoresSafeArea(.keyboard)  // 👈 Prevents keyboard from pushing overlay up
            )
            .alert("Clear canvas?", isPresented: $showClearAlert) {
                Button("Yes", role: .destructive) {
                    clearTrigger.toggle()
                }
                Button("No", role: .cancel) {}
            }
            .sheet(isPresented: $showPenOptionsSheet) {
                PenOptionsSheet(penSize: $penSize, penColor: $penColor) // NEW
            }
        }
    }
}

struct PenOptionsSheet: View {
    @Binding var penSize: CGFloat
    @Binding var penColor: Color

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Line Thickness: \(Int(penSize))")
                    .font(.headline)

                Slider(value: $penSize, in: 1...30, step: 1)
                    .padding()

                ColorPicker("Pen Color", selection: $penColor)
                    .padding()

                Spacer()
            }
            .padding()
            .navigationTitle("Pen Options")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
