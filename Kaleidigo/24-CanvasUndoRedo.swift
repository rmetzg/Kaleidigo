//
//  24-CanvasUndoRedo.swift
//  Kaleidigo
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
    @Binding var usePieShapedMode: Bool
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
            
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPicker(image: $photoPickerImage)
                    .onDisappear {
                                guard let loadedImage = photoPickerImage else { return }

                                if usePieShapedMode {
                                    let sliced = makeSixSliceComposite(from: loadedImage, canvasSize: canvasSize)
                                    canvasImage = sliced
                                    canvasHistory.append(sliced)
                                } else {
                                    canvasImage = loadedImage
                                    canvasHistory.append(loadedImage)
                                }

                                canUndo = true
                                redoStack.removeAll()
                                canRedo = false
                            }
            }
    }
    
    func makeSixSliceComposite(from image: UIImage, canvasSize: CGSize) -> UIImage {
        let side = min(canvasSize.width, canvasSize.height)
        let size = CGSize(width: side, height: side)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let center = CGPoint(x: side/2, y: side/2)
        let radius = side/2

        return renderer.image { ctx in
            let g = ctx.cgContext
            for i in 0..<6 {
                g.saveGState()
                g.translateBy(x: center.x, y: center.y)
                g.rotate(by: CGFloat(i) * .pi/3)
                g.translateBy(x: -center.x, y: -center.y)

                let path = CGMutablePath()
                path.move(to: center)
                path.addArc(center: center, radius: radius,
                            startAngle: 0, endAngle: .pi/3, clockwise: false)
                path.closeSubpath()
                g.addPath(path); g.clip()

                // rotate image inside wedge if desired
                g.translateBy(x: center.x, y: center.y)
                g.rotate(by: 2 * .pi / 3)   // 120°
                g.translateBy(x: -center.x, y: -center.y)

                let aspect = image.size.width / image.size.height
                let h = radius
                let w = h * aspect
                let mid = CGPoint(x: center.x, y: center.y - radius/2)
                image.draw(in: CGRect(x: mid.x - w/2, y: mid.y - h/2, width: w, height: h))
                g.restoreGState()
            }
        }
    }
}
