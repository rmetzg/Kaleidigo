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
        let renderer = UIGraphicsImageRenderer(size: canvasSize)
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let radius = min(canvasSize.width, canvasSize.height) / 2

        let imageZoom: CGFloat = 0.5  // <— Shrinks image to show more

        return renderer.image { context in
            let cgCtx = context.cgContext

            for i in 0..<6 {
                let angle = CGFloat(i) * 60.0

                cgCtx.saveGState()

                // Rotate context for this slice
                cgCtx.translateBy(x: center.x, y: center.y)
                cgCtx.rotate(by: angle.toRadians())
                cgCtx.translateBy(x: -center.x, y: -center.y)

                // Clip to wedge
                let wedgePath = CGMutablePath()
                wedgePath.move(to: center)
                wedgePath.addArc(center: center, radius: radius,
                                 startAngle: 0,
                                 endAngle: CGFloat(60).toRadians(),
                                 clockwise: false)
                wedgePath.closeSubpath()
                cgCtx.addPath(wedgePath)
                cgCtx.clip()

                // Rotate image by 120° inside wedge
                cgCtx.translateBy(x: center.x, y: center.y)
                cgCtx.rotate(by: (120).toRadians())
                cgCtx.translateBy(x: -center.x, y: -center.y)

                // Scale and center the image
                let imageSize = image.size
                let imageZoom: CGFloat = 0.5
                let imageZoomOffset: CGFloat = 0.0

                let imageAspectRatio = imageSize.width / imageSize.height

                // Scale height to match the pie wedge radius
                let scaledHeight = radius
                let scaledWidth = scaledHeight * imageAspectRatio

                // Still center the image at the midpoint of the wedge
                let pieSliceMidpoint = CGPoint(
                    x: center.x,
                    y: center.y - radius / 2
                )

                let imageOrigin = CGPoint(
                    x: pieSliceMidpoint.x - scaledWidth / 2,
                    y: pieSliceMidpoint.y - scaledHeight / 2
                )

                let drawRect = CGRect(origin: imageOrigin, size: CGSize(width: scaledWidth, height: scaledHeight))
                image.draw(in: drawRect)

                cgCtx.restoreGState()
            }
        }
    }
}
