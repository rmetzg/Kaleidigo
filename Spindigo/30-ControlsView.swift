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
            .overlay(
                VStack {
                    Spacer()
                    
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

                            Text("Undo     Redo")
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
                    .frame(height: 14 * DeviceScaling.scaleFactor)  // Optional: limit height
                    
                    HStack {
                        if !DeviceInfo.isPhone {
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
                            .accessibilityLabel("Save to Photos")
                            
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
                            
                            Spacer()
                            
                            // Trash (Clear) Button
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
                            .accessibilityLabel("Clear canvas")
                        }
                        
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        Spacer()
                        
                        // Undo Button
                        Button {
                            if canUndo { undoTrigger.toggle() }
                        } label: {
                            Image(systemName: "arrow.uturn.backward")
                                .font(.system(size: 28 * DeviceScaling.scaleFactor))
                                .padding(12 * DeviceScaling.scaleFactor)
                                .background(Color.gray.opacity(0.8))
                                .foregroundColor(canUndo ? .white : .gray)
                                .disabled(!canUndo)
                                .clipShape(Circle())
                                .shadow(radius: 5 * DeviceScaling.scaleFactor)
                        }
                        .accessibilityLabel("Undo last stroke")
                        
                        // Redo Button
                        Button {
                            if canRedo { redoTrigger.toggle() }
                        } label: {
                            Image(systemName: "arrow.uturn.forward")
                                .font(.system(size: 28 * DeviceScaling.scaleFactor))
                                .padding(12 * DeviceScaling.scaleFactor)
                                .background(Color.gray.opacity(0.8))
                                .foregroundColor(canRedo ? .white : .gray)
                                .disabled(redoStack.isEmpty)
                                .clipShape(Circle())
                                .shadow(radius: 5 * DeviceScaling.scaleFactor)
                        }
                        .accessibilityLabel("Redo last stroke")
                        
                        //      Spacer()
                        
                        // Pen Options Button
                        if !DeviceInfo.isPhone {
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
                        .accessibilityLabel("Pen options")
                    }
                    }
                    .padding(.horizontal, 20 * DeviceScaling.scaleFactor)
                    .padding(.bottom, -25 * DeviceScaling.scaleFactor)  // 👈 Lower them toward bottom here
                }
                .ignoresSafeArea(.keyboard)  // 👈 Prevents keyboard from pushing overlay up
            )
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
                    isPresented: $showPenOptionsSheet,
                    selectedQuickPenColor: $selectedQuickPenColor,
                    penEraser: $penEraser
                )
            }
        }
    }
}


