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
    @State private var showLoadImageAlert = false
    @State private var usePieShapedMode = false
    
    @State private var animationManager = AnimationCycleManager()
    
    @State private var showSpeedSheet = false
    @State private var showSaveLoadSheet = false
    @State private var showColorsSheet = false
    @State private var showPenOptionsSheet = false
    @State var selectedQuickPenColor: QuickPenColor? = nil
    
    


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
    @Binding var penEraser: Bool
    

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
            
            if DeviceInfo.isPhone {
                iPhonePopupButtonRow
            }

            CanvasDrawingArea(
                canvasSize: $canvasSize,
                canvasImage: $canvasImage,
                activePoints: $activePoints,
                fingerIsDown: $fingerIsDown,
                fingerLocation: $fingerLocation,
                currentTime: $currentTime,
                penEraser: $penEraser,
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
            
            .onChange(of: saveImageTrigger) { _, _ in
                if let image = canvasImage {
                    PhotoLibraryManager.saveImageToPhotos(image) { success in
                        print("Save to photos: \(success)")
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
                usePieShapedMode: $usePieShapedMode,
                canvasSize: canvasSize
            ))
        }
        .sheet(isPresented: $showAbout) {
            AboutSheet(isPresented: $showAbout)
        }
        .onChange(of: loadImageTrigger) { _, _ in
            showLoadImageAlert = true
        }

        .alert("Load Image", isPresented: $showLoadImageAlert) {
            Button("Load Normally") {
                usePieShapedMode = false
                showPhotoPicker = true
            }
            Button("Load as Pie Slices") {
                usePieShapedMode = true
                showPhotoPicker = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("How would you like to load the image?")
        }
    }
    
    
    private func drawOnImage(
        image: UIImage?,
        size: CGSize,
        activeDiameter: CGFloat,
        points: [CGPoint],
        color: Color,
        lineWidth: CGFloat,
        isEraser: Bool
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
            if isEraser {
                context.cgContext.setBlendMode(.clear)
                context.cgContext.setStrokeColor(UIColor.clear.cgColor)
            } else {
                context.cgContext.setBlendMode(.normal)
                context.cgContext.setStrokeColor(UIColor(color).cgColor)
            }
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
            lineWidth: penSize,
            isEraser: penEraser
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
    
    private var iPhonePopupButtonRow: some View {
        HStack(spacing: 32 * DeviceScaling.scaleFactor) {
            iPhonePopupButton(title: "Speed/Frame Rate", color: .blue) {
                showSpeedSheet = true
            }
            iPhonePopupButton(title: "Save/Load/Clear", color: .orange) {
                showSaveLoadSheet = true
            }
            iPhonePopupButton(title: "Colors", color: .purple) {
                showColorsSheet = true
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity)
        .background(Color.darkIndigo)
        .sheet(isPresented: $showSpeedSheet) {
            SpeedPopupSheet(
                spinRPM: $spinRPM,
                displayFrameRate: $displayFrameRate,
                cancelAnimation: cancelAnimationIfActive
            )
        }
        .sheet(isPresented: $showSaveLoadSheet) {
            SaveLoadClearSheet(
                saveImageTrigger: $saveImageTrigger,
                loadImageTrigger: $loadImageTrigger,
                clearTrigger: $clearTrigger
            )
        }
        .sheet(isPresented: $showColorsSheet) {
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
    
    private func iPhonePopupButton(title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Noteworthy", size: 32 * DeviceScaling.scaleFactor))
                .foregroundColor(.darkIndigo)
                .bold()
                .multilineTextAlignment(.center)
                .frame(width: 190 * DeviceScaling.scaleFactor,
                       height: 144 * DeviceScaling.scaleFactor, // ✅ Enough for 2 lines
                       alignment: .center)                     // ✅ Center text vertically
                .background(
                    RoundedRectangle(cornerRadius: 10 * DeviceScaling.scaleFactor)
                        .fill(Color.spindigoAccent)
                )
        }
    }
}

struct TopControlPanel: View {
    @Binding var spinRPM: Double
    @Binding var displayFrameRate: Int
    var cancelAnimation: () -> Void
    @Binding var animationManager: AnimationCycleManager

    var body: some View {
        VStack(spacing: 8 * DeviceScaling.scaleFactor) {
            HStack {
                Text("Spindigo")
                    .font(.custom("Noteworthy", size: 60 * DeviceScaling.scaleFactor))
                    .bold()
                    .foregroundColor(.yellow)
                    .padding(.top, -8)
                
                Spacer()
                
                HStack(spacing: 12 * DeviceScaling.scaleFactor) {
                    Button("Zero Spd") {
                        cancelAnimation()
                        spinRPM = 0
                    }
                    .font(.custom("Noteworthy", size: 32 * DeviceScaling.scaleFactor))
                    .foregroundColor(.white)
                    .bold()
                    .padding(.horizontal, 12 * DeviceScaling.scaleFactor)
                    .padding(.vertical, 6 * DeviceScaling.scaleFactor)
                    .background(
                        RoundedRectangle(cornerRadius: 10 * DeviceScaling.scaleFactor)
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
                    .font(.custom("Noteworthy", size: 32 * DeviceScaling.scaleFactor))
                    .foregroundColor(.white)
                    .bold()
                    .animatedSpindigoGlow(animationManager.isAnimating)
                }
            }
            
            if !DeviceInfo.isPhone {
                HStack(spacing: 12 * DeviceScaling.scaleFactor) {
                    Text("Speed: \(Int(spinRPM)) RPM")
                        .foregroundColor(.white)
                        .font(.system(size: 20 * DeviceScaling.scaleFactor))
                        .frame(width: 170 * DeviceScaling.scaleFactor, alignment: .leading)
                    
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
            }
            
            if !DeviceInfo.isPhone {
            HStack(spacing: 12 * DeviceScaling.scaleFactor) {
                Text("Frame: \(displayFrameRate) fps")
                    .foregroundColor(.white)
                    .font(.system(size: 20 * DeviceScaling.scaleFactor))
                    .frame(width: 170 * DeviceScaling.scaleFactor, alignment: .leading)
                
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
        }
        .padding(.horizontal)
        .padding(.top, 4 * DeviceScaling.scaleFactor)
        .padding(.bottom, 6 * DeviceScaling.scaleFactor)
        .background(Color.darkIndigo)
    }
}

struct AnimationCycleManager {
    let presets: [(rpm: Double, fps: Int)] = [
        (240, 23),
        (240, 24),
        (240, 25),
        (140, 18),
        (190, 22),
        (103, 15)
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
            .padding(.horizontal, 12 * DeviceScaling.scaleFactor)
            .padding(.vertical, 6 * DeviceScaling.scaleFactor)
            .background(
                RoundedRectangle(cornerRadius: 10 * DeviceScaling.scaleFactor)
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
            .padding(.horizontal, 12 * DeviceScaling.scaleFactor)
            .padding(.vertical, 6 * DeviceScaling.scaleFactor)
            .background(
                RoundedRectangle(cornerRadius: 10 * DeviceScaling.scaleFactor)
                    .fill(active ? Color.clear : Color.spindigoAccent)
                    .animation(active ? .easeInOut(duration: 1.75).repeatForever(autoreverses: true) : .default, value: active)
            )
    }
}



