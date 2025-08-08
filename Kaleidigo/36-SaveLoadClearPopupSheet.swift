//
//  SaveLoadClearPopupSheet.swift
//  Kaleidigo
//
//  Created by Alan Metzger on 8/5/25.
//

import SwiftUI

struct SaveLoadClearSheet: View {
    @Binding var saveImageTrigger: Bool
    @Binding var loadImageTrigger: Bool
    @Binding var clearTrigger: Bool
    
    @State private var showSaveConfirmation = false
    
    @Environment(\.dismiss) private var dismiss  // Add this line

    // Calculate target width based on screen
    private let buttonWidth = UIScreen.main.bounds.width * 0.66

    var body: some View {
        VStack(spacing: 24 * DeviceScaling.scaleFactor) {
            Text("Save / Load / Clear")
                .font(.title3)
                .foregroundStyle(.yellow)
                .bold()
                .padding(.top)
                .padding(.bottom)

            Button {
                showSaveConfirmation = true  // Just show the confirmation prompt
            } label: {
                Label("Save to Photos", systemImage: "square.and.arrow.up")
                    .frame(width: buttonWidth)
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom)
            .alert("Save Canvas?", isPresented: $showSaveConfirmation) {
                Button("Yes", role: .none) {
                    saveImageTrigger = true
                }
                Button("No", role: .cancel) { }
            } message: {
                Text("Do you want to save the current canvas to the Photos app?")
            }

            Button {
                loadImageTrigger = true
            } label: {
                Label("Load from Photos", systemImage: "photo")
                    .frame(width: buttonWidth)
            }
            .buttonStyle(.bordered)
            .padding(.bottom)

            Button(role: .destructive) {
                clearTrigger.toggle()
                dismiss()
            } label: {
                Label("Clear Canvas", systemImage: "trash")
                    .frame(width: buttonWidth)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
    }
}
