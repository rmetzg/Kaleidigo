//
//  24-CanvasUndoRedo.swift
//  Spindigo
//
//  Created by Alan Metzger on 8/3/25.
//

import SwiftUI

struct CanvasUndoRedo: ViewModifier {
    @Binding var canvasImage: UIImage?
    @Binding var canvasHistory: [UIImage]
    @Binding var redoStack: [UIImage]
    @Binding var canUndo: Bool
    @Binding var canRedo: Bool
    @Binding var undoTrigger: Bool
    @Binding var redoTrigger: Bool
    @Binding var saveImageTrigger: Bool
    @Binding var loadImageTrigger: Bool
    @Binding var photoPickerImage: UIImage?
    @Binding var showPhotoPicker: Bool
    let canvasSize: CGSize

    func body(content: Content) -> some View {
        content
            .onChange(of: undoTrigger) { _, _ in
                if let current = canvasImage {
                    // 🛡️ Avoid pushing duplicate if identical to last in history
                    if canvasHistory.last != current {
                        redoStack.append(current)
                    }
                }

                if let last = canvasHistory.popLast() {
                    canvasImage = last
                } else {
                    canvasImage = nil
                }

                canUndo = !canvasHistory.isEmpty
                canRedo = !redoStack.isEmpty
            }
            .onChange(of: redoTrigger) { _, _ in
                if let redoImage = redoStack.popLast() {
                    if let current = canvasImage {
                        canvasHistory.append(current)
                    }
                    canvasImage = redoImage
                }
                canUndo = !canvasHistory.isEmpty
                canRedo = !redoStack.isEmpty
            }
            .onChange(of: saveImageTrigger) { _, _ in
                if let image = canvasImage {
                    PhotoLibraryManager.saveImageToPhotos(image) { success in
                        print("Save to photos: \(success)")
                    }
                }
            }
//            .onChange(of: loadImageTrigger) { _, _ in
//                showPhotoPicker = true
//            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker(image: $photoPickerImage)
                    .onDisappear {
                        if let loadedImage = photoPickerImage {
                            canvasImage = loadedImage
                            canvasHistory.append(loadedImage)
                            canUndo = true
                            redoStack.removeAll()
                            canRedo = false
                        }
                    }
            }
    }
}
