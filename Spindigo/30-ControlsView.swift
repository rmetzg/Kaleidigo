//
//  ControlsView.swift
//  Spindigo
//
//  Created by Alan Metzger on 7/28/25.
//

import SwiftUI

struct ControlsView: View {
    @Binding var penSize: CGFloat
    @Binding var displayFrameRate: Int
    @Binding var spinRPM: Double
    @Binding var clearTrigger: Bool
    @Binding var isActive: Bool
    @Binding var redoStack: [UIImage]
    
//    @State private var redoStack: [UIImage] = []
    

    @State private var showClearAlert = false
    @State private var showPenOptionsSheet = false
    @State private var penColor: Color = .blue
    @State private var canvasBackgroundColor: Color = .white
    @State private var undoTrigger = false
    @State private var redoTrigger = false
    @State private var canUndo = false
    @State private var canRedo = false
    @State private var saveImageTrigger = false
    @State private var loadImageTrigger = false
    @State private var showSaveAlert = false
    @State var selectedQuickPenColor: QuickPenColor? = nil
    @State var penEraser: Bool = false

    var body: some View {
        VStack(spacing: 0 * DeviceScaling.scaleFactor) {
            
            CanvasView(
                displayFrameRate: $displayFrameRate,
                spinRPM: $spinRPM,
                clearTrigger: $clearTrigger,
                penSize: $penSize,
                penColor: $penColor,
                canvasBackgroundColor: $canvasBackgroundColor,
                isActive: $isActive,
                undoTrigger: $undoTrigger,
                redoTrigger: $redoTrigger,
                canUndo: $canUndo,
                canRedo: $canRedo,
                saveImageTrigger: $saveImageTrigger,
                loadImageTrigger: $loadImageTrigger,
                penEraser: $penEraser
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity) // ✅ Ensure CanvasView fills the space
            .overlay(alignment: .bottom) {
                GeometryReader { proxy in
                    if DeviceInfo.isPhone {
                        VStack {
                            Spacer()
                        
                            HStack {
                                VStack(spacing: 4 * DeviceScaling.scaleFactor) {
                                    Text("Undo")
                                        .font(.system(size: 14 * DeviceScaling.scaleFactor * 1.5))
                                        .foregroundStyle(.white)
                                    Button {
                                        if canUndo { undoTrigger.toggle() }
                                    } label: {
                                        Image(systemName: "arrow.uturn.backward")
                                            .font(.system(size: 28 * DeviceScaling.scaleFactor * 1.5))
                                            .padding(12 * DeviceScaling.scaleFactor * 1.5)
                                            .background(Color.gray.opacity(0.8))
                                            .foregroundColor(canUndo ? .white : .gray)
                                            .clipShape(Circle())
                                            .shadow(radius: 5 * DeviceScaling.scaleFactor)
                                    }
                                    .disabled(!canUndo)
                                    .accessibilityLabel("Undo last stroke")
                                }

                                Spacer()

                                VStack(spacing: 4 * DeviceScaling.scaleFactor) {
                                    Text("Redo")
                                        .font(.system(size: 14 * DeviceScaling.scaleFactor * 1.5))
                                        .foregroundStyle(.white)
                                    Button {
                                        if canRedo { redoTrigger.toggle() }
                                    } label: {
                                        Image(systemName: "arrow.uturn.forward")
                                            .font(.system(size: 28 * DeviceScaling.scaleFactor * 1.5))
                                            .padding(12 * DeviceScaling.scaleFactor * 1.5)
                                            .background(Color.gray.opacity(0.8))
                                            .foregroundColor(canRedo ? .white : .gray)
                                            .clipShape(Circle())
                                            .shadow(radius: 5 * DeviceScaling.scaleFactor)
                                    }
                                    .disabled(redoStack.isEmpty)
                                    .accessibilityLabel("Redo last stroke")
                                }
                            }
                        .padding(.horizontal, 24 * DeviceScaling.scaleFactor)
                        .padding(.bottom, proxy.safeAreaInsets.bottom + 12)
                    }
                    } else {
                        VStack {
                            Spacer()
                            VStack(spacing: 12 * DeviceScaling.scaleFactor) {
                                GeometryReader { geo in
                                    HStack(spacing: 0 * DeviceScaling.scaleFactor) {
                                        Text("")
                                            .frame(width: geo.size.width * 0.023, alignment: .center)
                                            .font(.system(size: 17 * DeviceScaling.scaleFactor))

                                        Text("Save      Load")
                                            .frame(width: geo.size.width * 0.16, alignment: .center)
                                            .font(.system(size: 17 * DeviceScaling.scaleFactor))

                                        Text(" ")
                                            .frame(width: geo.size.width * 0.55, alignment: .center)
                                            .font(.system(size: 17 * DeviceScaling.scaleFactor))

                                        Text(" Undo    Redo")
                                            .frame(width: geo.size.width * 0.16, alignment: .center)
                                            .font(.system(size: 17 * DeviceScaling.scaleFactor))

                                        Text(" ")
                                            .frame(width: geo.size.width * 0.008, alignment: .center)
                                            .font(.system(size: 17 * DeviceScaling.scaleFactor))

                                        Text("Colors")
                                            .frame(width: geo.size.width * 0.08, alignment: .center)
                                            .font(.system(size: 17 * DeviceScaling.scaleFactor))

                                        Text("")
                                            .frame(width: geo.size.width * 0.03, alignment: .center)
                                            .font(.system(size: 17 * DeviceScaling.scaleFactor))
                                    }
                                }
                                .padding(.top, 20 * DeviceScaling.scaleFactor)
                                .frame(height: 14 * DeviceScaling.scaleFactor)

                                HStack {
                                    // LEFT GROUP
                                    HStack(spacing: 12 * DeviceScaling.scaleFactor) {
                                        Button {
                                            showSaveAlert = true
                                        } label: {
                                            Image(systemName: "square.and.arrow.up")
                                                .font(.system(size: 28 * DeviceScaling.scaleFactor))
                                                .padding(12 * DeviceScaling.scaleFactor)
                                                .background(Color.gray.opacity(0.8))
                                                .foregroundColor(.white)
                                                .clipShape(Circle())
                                                .shadow(radius: 5 * DeviceScaling.scaleFactor)
                                        }

                                        Button {
                                            loadImageTrigger.toggle()
                                        } label: {
                                            Image(systemName: "square.and.arrow.down")
                                                .font(.system(size: 28 * DeviceScaling.scaleFactor))
                                                .padding(12 * DeviceScaling.scaleFactor)
                                                .background(Color.gray.opacity(0.8))
                                                .foregroundColor(.white)
                                                .clipShape(Circle())
                                                .shadow(radius: 5 * DeviceScaling.scaleFactor)
                                        }

                                        Button {
                                            showClearAlert = true
                                        } label: {
                                            Image(systemName: "trash")
                                                .font(.system(size: 28 * DeviceScaling.scaleFactor))
                                                .padding(12 * DeviceScaling.scaleFactor)
                                                .background(Color.red.opacity(0.8))
                                                .foregroundColor(.white)
                                                .clipShape(Circle())
                                                .shadow(radius: 5 * DeviceScaling.scaleFactor)
                                        }
                                    }

                                    Spacer()

                                    // RIGHT GROUP
                                    HStack(spacing: 12 * DeviceScaling.scaleFactor) {
                                        Button {
                                            if canUndo { undoTrigger.toggle() }
                                        } label: {
                                            Image(systemName: "arrow.uturn.backward")
                                                .font(.system(size: 28 * DeviceScaling.scaleFactor))
                                                .padding(12 * DeviceScaling.scaleFactor)
                                                .background(Color.gray.opacity(0.8))
                                                .foregroundColor(canUndo ? .white : .gray)
                                                .clipShape(Circle())
                                                .shadow(radius: 5 * DeviceScaling.scaleFactor)
                                        }
                                        .disabled(!canUndo)

                                        Button {
                                            if canRedo { redoTrigger.toggle() }
                                        } label: {
                                            Image(systemName: "arrow.uturn.forward")
                                                .font(.system(size: 28 * DeviceScaling.scaleFactor))
                                                .padding(12 * DeviceScaling.scaleFactor)
                                                .background(Color.gray.opacity(0.8))
                                                .foregroundColor(canRedo ? .white : .gray)
                                                .clipShape(Circle())
                                                .shadow(radius: 5 * DeviceScaling.scaleFactor)
                                        }
                                        .disabled(redoStack.isEmpty)

                                        Button {
                                            showPenOptionsSheet = true
                                        } label: {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.gray.opacity(0.4))
                                                    .frame(width: 54 * DeviceScaling.scaleFactor, height: 54 * DeviceScaling.scaleFactor)
                                                    .shadow(radius: 5 * DeviceScaling.scaleFactor)

                                                VStack(spacing: 3 * DeviceScaling.scaleFactor) {
                                                    Rectangle().fill(Color.green).frame(width: 20 * DeviceScaling.scaleFactor, height: 4 * DeviceScaling.scaleFactor)
                                                    Rectangle().fill(Color.blue).frame(width: 20 * DeviceScaling.scaleFactor, height: 6 * DeviceScaling.scaleFactor)
                                                    Rectangle().fill(Color.red).frame(width: 20 * DeviceScaling.scaleFactor, height: 8 * DeviceScaling.scaleFactor)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20 * DeviceScaling.scaleFactor)
                                .padding(.top, 20 * DeviceScaling.scaleFactor)
                            }
                            .padding(.bottom, -25 * DeviceScaling.scaleFactor)
                        }
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
            
            .alert("Clear canvas?", isPresented: $showClearAlert) {
                Button("Yes", role: .destructive) {
                    clearTrigger.toggle()
                }
                Button("No", role: .cancel) {}
            }
            .alert("Do you want to save the canvas image to Photos?", isPresented: $showSaveAlert) {
                Button("Yes") {
                    saveImageTrigger.toggle()
                }
                Button("No", role: .cancel) {}
            }
            .sheet(isPresented: $showPenOptionsSheet) {
                PenOptionsSheet(
                    penSize: $penSize,
                    penColor: $penColor,
                    canvasBackgroundColor: $canvasBackgroundColor,
                    selectedQuickPenColor: $selectedQuickPenColor,
                    penEraser: $penEraser
                )
            }
        }
    }
}


