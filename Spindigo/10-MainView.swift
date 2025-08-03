//
//  ContentView.swift
//  Spindigo
//
//  Created by Alan Metzger on 7/27/25.
//

import SwiftUI


struct MainView: View {
    @State private var penSize: CGFloat = 10.0
    @State private var displayFrameRate = 30
    @State private var spinRPM = 36.0
    @State private var clearTrigger = false
    @State private var isActive = true
    @State private var redoStack: [UIImage] = []

    @State private var penColor: Color = .blue
    @State private var undoTrigger = false
    @State private var redoTrigger = false
    @State private var canUndo = false
    @State private var canRedo = false
    @State private var saveImageTrigger = false
    @State private var loadImageTrigger = false

    var body: some View {
        VStack(spacing: 0) {
            ControlsView(
                penSize: $penSize,
                displayFrameRate: $displayFrameRate,
                spinRPM: $spinRPM,
                clearTrigger: $clearTrigger,
                isActive: $isActive,
                redoStack: $redoStack
            )
        }
    }
}


