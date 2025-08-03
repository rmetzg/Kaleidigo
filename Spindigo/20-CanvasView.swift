//
//  CanvasView.swift
//  Spindigo
//
//  Created by Alan Metzger on 7/28/25.
//

import SwiftUI


struct CanvasView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var canvasSize: CGSize = .zero
    @State private var currentTime: Date = Date()
    @State private var renderTimer: Timer? = nil
    @State private var sampleTimer: Timer? = nil

    @State private var activePoints: [PolarSample] = []
    @State private var finishedPaths: [OrbitingPath] = []

    @State private var fingerIsDown = false
    @State private var fingerStartTime: Date = .distantPast
    @State private var fingerLocation: CGPoint? = nil
    
    @State private var canvasImage: UIImage? = nil
    @State private var fingerLiftTime: Date = .distantPast
    @State private var strokeStartTime: Date? = nil
    @State private var canvasHistory: [UIImage] = []
    @State private var redoStack: [UIImage] = []
    @State private var isSeededWithBlankImage = false
    @State private var showPhotoPicker = false
    @State private var photoPickerImage: UIImage?
    @State private var showAbout = false
    
    @State private var animationManager = AnimationCycleManager()

    @Binding var displayFrameRate: Int
    @Binding var spinRPM: Double
    @Binding var clearTrigger: Bool
    @Binding var penSize: CGFloat
    @Binding var penColor: Color
    @Binding var canvasBackgroundColor: Color
    @Binding var isActive: Bool
    @Binding var undoTrigger: Bool
    @Binding var redoTrigger: Bool
    @Binding var canUndo: Bool
    @Binding var canRedo: Bool
    @Binding var saveImageTrigger: Bool
    @Binding var loadImageTrigger: Bool
    

    struct PolarSample {
        let radius: CGFloat
        let angleAtZero: Double
        let timestamp: Date
    }

    var body: some View {
        VStack(spacing: 0) {
            TopControlPanel(
                spinRPM: $spinRPM,
                displayFrameRate: $displayFrameRate,
                cancelAnimation: cancelAnimationIfActive,
                animationManager: $animationManager
            )

            CanvasDrawingArea(
                canvasSize: $canvasSize,
                canvasImage: $canvasImage,
                activePoints: $activePoints,
                fingerIsDown: $fingerIsDown,
                fingerLocation: $fingerLocation,
                currentTime: $currentTime,
                penSize: penSize,
                penColor: penColor,
                canvasBackgroundColor: canvasBackgroundColor,
                spinRPM: spinRPM
            )
            .onAppear {
                if isActive { startRenderLoop() }

                if canvasHistory.isEmpty {
                    let blank = UIGraphicsImageRenderer(size: canvasSize).image { ctx in
                        ctx.cgContext.setFillColor(UIColor.clear.cgColor)
                        ctx.cgContext.fill(CGRect(origin: .zero, size: canvasSize))
                    }
                    canvasHistory.append(blank)
                }

                canUndo = canvasHistory.count > 1
            }
            .onDisappear {
                stopRenderLoop()
                stopSampleLoop()
            }
            .onChange(of: displayFrameRate) { _, _ in
                if isActive {
                    startRenderLoop()
                }
            }
            .onChange(of: isActive) { _, newValue in
                newValue ? startRenderLoop() : stopRenderLoop()
            }
            .onChange(of: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    if isActive { startRenderLoop() }
                default:
                    stopRenderLoop()
                    stopSampleLoop()
                }
            }
            .onChange(of: clearTrigger) { _, _ in
                if let currentImage = canvasImage {
                    canvasHistory.append(currentImage)  // ✅ Save pre-clear state
                }

                // 🧼 Clear state
                activePoints.removeAll()
                fingerIsDown = false
                redoStack.removeAll()

                // ✅ Just set canvasImage to blank — don’t push to history
                let blank = UIGraphicsImageRenderer(size: canvasSize).image { ctx in
                    ctx.cgContext.setFillColor(UIColor.clear.cgColor)
                    ctx.cgContext.fill(CGRect(origin: .zero, size: canvasSize))
                }

                canvasImage = blank

                canUndo = canvasHistory.count > 1
                canRedo = false
            }
//            .onChange(of: undoTrigger) { _, _ in
//                if let current = canvasImage {
//                    redoStack.append(current)
//                }
//                if let last = canvasHistory.popLast() {
//                    canvasImage = last
//                } else {
//                    canvasImage = nil
//                }
//                canUndo = !canvasHistory.isEmpty
//                canRedo = !redoStack.isEmpty
//            }
//            .onChange(of: redoTrigger) { _, _ in
//                if let redoImage = redoStack.popLast() {
//                    if let current = canvasImage {
//                        canvasHistory.append(current)
//                    }
//                    canvasImage = redoImage
//                }
//                canUndo = !canvasHistory.isEmpty
//                canRedo = !redoStack.isEmpty
//            }
            .onChange(of: saveImageTrigger) { _, _ in
                if let image = canvasImage {
                    PhotoLibraryManager.saveImageToPhotos(image) { success in
                        print("Save to photos: \(success)")
                    }
                }
            }
            .onChange(of: loadImageTrigger) { _, _ in
                showPhotoPicker = true
            }
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
            .modifier(
                DrawingGestureModifier(
                    fingerIsDown: $fingerIsDown,
                    fingerLocation: $fingerLocation,
                    activePoints: $activePoints,
                    startSampleLoop: startSampleLoop,
                    stopSampleLoop: stopSampleLoop,
                    commitStroke: commitStroke,
                    recordStrokeStart: {
                        let now = Date()
                        fingerStartTime = now
                        strokeStartTime = now
                    }
                )
            )
            .modifier(CanvasUndoRedo(
                canvasImage: $canvasImage,
                canvasHistory: $canvasHistory,
                redoStack: $redoStack,
                canUndo: $canUndo,
                canRedo: $canRedo,
                undoTrigger: $undoTrigger,
                redoTrigger: $redoTrigger,
                saveImageTrigger: $saveImageTrigger,
                loadImageTrigger: $loadImageTrigger,
                photoPickerImage: $photoPickerImage,
                showPhotoPicker: $showPhotoPicker,
                canvasSize: canvasSize
            ))
        }
        .sheet(isPresented: $showAbout) {
            AboutSheet(isPresented: $showAbout)
        }
    }
    
    
    private func drawOnImage(
        image: UIImage?,
        size: CGSize,
        activeDiameter: CGFloat,
        points: [CGPoint],
        color: Color,
        lineWidth: CGFloat
    ) -> UIImage {
        let rendererSize = CGSize(width: activeDiameter, height: activeDiameter)
        let renderer = UIGraphicsImageRenderer(size: rendererSize)

        return renderer.image { context in
            // Translate to center drawing in the square
            let offsetX = (size.width - activeDiameter) / 2
            let offsetY = (size.height - activeDiameter) / 2
            let translation = CGAffineTransform(translationX: -offsetX, y: -offsetY)
            
            image?.draw(in: CGRect(origin: .zero, size: rendererSize), blendMode: .normal, alpha: 1.0)

            let uiColor = UIColor(color)
            context.cgContext.setStrokeColor(uiColor.cgColor)
            context.cgContext.setLineWidth(lineWidth)
            context.cgContext.setLineCap(.round)

            guard points.count > 1 else { return }

            context.cgContext.beginPath()
            context.cgContext.move(to: points[0].applying(translation))
            for pt in points.dropFirst() {
                context.cgContext.addLine(to: pt.applying(translation))
            }
            context.cgContext.strokePath()
        }
    }
    
    private func commitStroke() {
        let now = Date()
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let activeDiameter = min(canvasSize.width, canvasSize.height) - 10

        let rotationAtLift = angleSince(.distantPast, now: now)

        let renderedPoints = activePoints.map { sample in
            let angleNow = sample.angleAtZero + angleSince(sample.timestamp, now: now)
            let correctedAngle = angleNow - rotationAtLift
            return CGPoint(
                x: center.x + sample.radius * cos(correctedAngle.toRadians()),
                y: center.y + sample.radius * sin(correctedAngle.toRadians())
            )
        }

        // 🧠 Save current canvas before modifying it
        if let currentImage = canvasImage {
            canvasHistory.append(currentImage)
        }
        redoStack.removeAll()
        canUndo = !canvasHistory.isEmpty
        canRedo = false

        canvasImage = drawOnImage(
            image: canvasImage,
            size: canvasSize,
            activeDiameter: activeDiameter,
            points: renderedPoints,
            color: penColor,
            lineWidth: penSize
        )

        activePoints.removeAll()
    }

    private func startRenderLoop() {
        renderTimer?.invalidate()
        renderTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / Double(displayFrameRate), repeats: true) { _ in
            currentTime = Date()
        }
    }

    private func stopRenderLoop() {
        renderTimer?.invalidate()
        renderTimer = nil
    }

    private func startSampleLoop() {
        sampleTimer?.invalidate()
        sampleTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            guard let location = fingerLocation else { return }
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let dx = location.x - center.x
            let dy = location.y - center.y
            let radius = hypot(dx, dy)
            let angle = atan2(dy, dx).toDegrees()
            activePoints.append(PolarSample(radius: radius, angleAtZero: angle, timestamp: Date()))
        }
    }

    private func stopSampleLoop() {
        sampleTimer?.invalidate()
        sampleTimer = nil
    }

    private func angleSince(_ start: Date, now: Date) -> Double {
        let elapsed = now.timeIntervalSince(start)
        let degreesPerSecond = spinRPM * 360.0 / 60.0
        return elapsed * degreesPerSecond
    }

    private func rotate(_ point: CGPoint, around center: CGPoint, by degrees: Double) -> CGPoint {
        let dx = point.x - center.x
        let dy = point.y - center.y
        let r = hypot(dx, dy)
        let angle = atan2(dy, dx) + degrees.toRadians()

        return CGPoint(
            x: center.x + r * cos(angle),
            y: center.y + r * sin(angle)
        )
    }
    
    private func cancelAnimationIfActive() {
        if animationManager.isAnimating {
            animationManager = AnimationCycleManager() // Reset to defaults
        }
    }
}

struct TopControlPanel: View {
    @Binding var spinRPM: Double
    @Binding var displayFrameRate: Int
    var cancelAnimation: () -> Void
    @Binding var animationManager: AnimationCycleManager

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Spindigo")
                    .font(.custom("Noteworthy", size: 60))
                    .bold()
                    .foregroundColor(.yellow)
                    .padding(.top, -8)

                Spacer()

                HStack(spacing: 12) {
                    Button("Zero Spd") {
                        cancelAnimation()
                        spinRPM = 0
                    }
                    .font(.custom("Noteworthy", size: 32))
                    .foregroundColor(.white)
                    .bold()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.spindigoAccent)
                    )

                    Button("Animate") {
                        if !animationManager.isAnimating {
                            animationManager.startCycle(currentRPM: spinRPM, currentFPS: displayFrameRate)
                        } else {
                            animationManager.advanceCycle()
                        }

                        if animationManager.shouldRestoreOriginal {
                            spinRPM = animationManager.originalRPM
                            displayFrameRate = animationManager.originalFPS
                        } else if let preset = animationManager.currentPreset {
                            spinRPM = preset.0
                            displayFrameRate = preset.1
                        }
                    }
                    .font(.custom("Noteworthy", size: 32))
                    .foregroundColor(.white)
                    .bold()
                    .animatedSpindigoGlow(animationManager.isAnimating)
                }
            }

            HStack(spacing: 12) {
                Text("Speed: \(Int(spinRPM)) RPM")
                    .foregroundColor(.white)
                    .font(.title3)
                    .frame(width: 150, alignment: .leading)

                Slider(value: Binding(
                    get: { spinRPM },
                    set: {
                        cancelAnimation()
                        spinRPM = $0
                    }
                ), in: -240...240, step: 1)

                Button("–") {
                    cancelAnimation()
                    spinRPM = max(spinRPM - 1, -240)
                }
                .controlMiniButtonStyle()

                Button("+") {
                    cancelAnimation()
                    spinRPM = min(spinRPM + 1, 240)
                }
                .controlMiniButtonStyle()
            }

            HStack(spacing: 12) {
                Text("Frame: \(displayFrameRate) fps")
                    .foregroundColor(.white)
                    .font(.title3)
                    .frame(width: 150, alignment: .leading)

                Slider(value: Binding(
                    get: { Double(displayFrameRate) },
                    set: {
                        let newValue = Int($0)
                        if newValue != displayFrameRate {
                            cancelAnimation()
                            displayFrameRate = newValue
                        }
                    }
                ), in: 1...120, step: 1)

                Button("–") {
                    cancelAnimation()
                    displayFrameRate = max(displayFrameRate - 1, 1)
                }
                .controlMiniButtonStyle()

                Button("+") {
                    cancelAnimation()
                    displayFrameRate = min(displayFrameRate + 1, 120)
                }
                .controlMiniButtonStyle()
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
        .padding(.bottom, 6)
        .background(Color.darkIndigo)
    }
}

struct AnimationCycleManager {
    let presets: [(rpm: Double, fps: Int)] = [
        (240, 10),
        (140, 18),
        (190, 22)
    ]
    
    private(set) var originalRPM: Double = 0
    private(set) var originalFPS: Int = 0
    private(set) var currentIndex: Int = -1  // -1 means "off"
    
    mutating func startCycle(currentRPM: Double, currentFPS: Int) {
        originalRPM = currentRPM
        originalFPS = currentFPS
        currentIndex = 0
    }
    
    mutating func advanceCycle() {
        if currentIndex >= 0 && currentIndex < presets.count - 1 {
            currentIndex += 1
        } else {
            currentIndex = -1 // exit animation mode
        }
    }
    
    var isAnimating: Bool {
        currentIndex != -1
    }
    
    var currentPreset: (Double, Int)? {
        guard isAnimating else { return nil }
        return presets[currentIndex]
    }
    
    var shouldRestoreOriginal: Bool {
        currentIndex == -1
    }
}

struct AnimateButtonBackground: ViewModifier {
    @State private var animate = false

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(animate ? Color.spindigoAccent : Color.darkIndigo)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: animate)
            )
            .onAppear {
                animate = true
            }
    }
}

extension View {
    func animatedSpindigoGlow(_ active: Bool) -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(active ? Color.clear : Color.spindigoAccent)
                    .animation(active ? .easeInOut(duration: 1.75).repeatForever(autoreverses: true) : .default, value: active)
            )
    }
}



