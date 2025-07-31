//
//  DrawingCanvasView.swift
//  Spindigo
//
//  Created by Alan Metzger on 7/28/25.
//

import SwiftUI


struct DrawingCanvasView: View {
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

    @Binding var displayFrameRate: Int
    @Binding var spinRPM: Double
    @Binding var clearTrigger: Bool
    @Binding var penSize: CGFloat
    @Binding var penColor: Color
    @Binding var isActive: Bool

    struct PolarSample {
        let radius: CGFloat
        let angleAtZero: Double
        let timestamp: Date
    }

    var body: some View {
        VStack(spacing: 0) {
            // ✅ Slider at the top
//            VStack {
//                Text("Spin Rate: \(Int(spinRPM)) RPM")
//                    .font(.caption)
//                    .padding(.top, 6)
//                Slider(value: $spinRPM, in: -120...120, step: 1)
//                    .padding([.horizontal, .bottom], 10)
//            }
//            .background(Color(white: 0.95))
            
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("RPM")
                        .font(.headline)
                        .foregroundStyle(.black)

                    HStack {
                        Button(action: {
                            spinRPM = max(spinRPM - 1, -240)
                        }) {
                            Text("-240")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.blue)
                                )
                        }

                        Slider(value: $spinRPM, in: -240...240, step: 1)

                        Button(action: {
                            spinRPM = min(spinRPM + 1, 240)
                        }) {
                            Text("240")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.blue)
                                )
                        }
                    }

                    Text("\(Int(spinRPM)) RPM")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                VStack(spacing: 4) {
                    Text("Frame Rate")
                        .font(.headline)
                        .foregroundStyle(.black)

                    HStack {
                        Button(action: {
                            displayFrameRate = max(displayFrameRate - 1, 1)
                        }) {
                            Text("1")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.blue)
                                )
                        }

                        Slider(value: Binding(
                            get: { Double(displayFrameRate) },
                            set: {
                                let newValue = Int($0)
                                if newValue != displayFrameRate {
                                    displayFrameRate = newValue
                                    startRenderLoop()
                                }
                            }
                        ), in: 1...120, step: 1)

                        Button(action: {
                            displayFrameRate = min(displayFrameRate + 1, 120)
                        }) {
                            Text("120")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.blue)
                                )
                        }
                    }

                    Text("\(displayFrameRate) fps")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .background(Color(white: 0.95))
            
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let activeDiameter = min(geo.size.width, geo.size.height) - 10

                ZStack {
                    // Outer background (entire screen)
                    Color.black.ignoresSafeArea()

                    // White drawing area inside the circle only
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: activeDiameter, height: activeDiameter)
                            .position(center)
                        
                        // Canvas image, rotated by time-based angle
                        if let image = canvasImage {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: activeDiameter, height: activeDiameter)
                                .rotationEffect(.degrees(angleSince(.distantPast, now: currentTime))) // spins continuously
                                .position(center)
                                .mask(
                                    Circle()
                                        .frame(width: activeDiameter, height: activeDiameter)
                                )
                        }

                        Circle()
                            .fill(Color.black)
                            .frame(width: 5, height: 5)
                            .position(center)

                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                            .frame(width: activeDiameter, height: activeDiameter)
                            .position(center)

                        ZStack {
                            
                            
                            
//                            ForEach(0..<finishedPaths.count, id: \.self) { i in
//                                let path = finishedPaths[i]
//                                let offset = angleSince(path.creationTime, now: currentTime)
//
//                                Path { p in
//                                    for (index, point) in path.points.enumerated() {
//                                        let rotated = rotate(point, around: center, by: offset)
//                                        if index == 0 {
//                                            p.move(to: rotated)
//                                        } else {
//                                            p.addLine(to: rotated)
//                                        }
//                                    }
//                                }
//                                .stroke(path.color, lineWidth: path.lineWidth)
//                            }

                            if fingerIsDown {
                                Path { p in
                                    for (index, polar) in activePoints.enumerated() {
                                        let rotatedAngle = polar.angleAtZero + angleSince(polar.timestamp, now: currentTime)
                                        let point = CGPoint(
                                            x: center.x + polar.radius * cos(rotatedAngle.toRadians()),
                                            y: center.y + polar.radius * sin(rotatedAngle.toRadians())
                                        )
                                        if index == 0 {
                                            p.move(to: point)
                                        } else {
                                            p.addLine(to: point)
                                        }
                                    }
                                }
                                .stroke(penColor.opacity(0.5), lineWidth: penSize)
                            }
                        }
                        .mask(
                            Circle()
                                .frame(width: activeDiameter, height: activeDiameter)
                                .position(center)
                        )
                    }
                }
                .onAppear {
                    canvasSize = geo.size
                    if isActive { startRenderLoop() }
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
                .onChange(of: isActive) { oldValue, newValue in
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
                    activePoints.removeAll()
                    fingerIsDown = false
                    canvasImage = nil  // ✅ Clear the persistent drawing
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !fingerIsDown {
                                let now = Date()
                                fingerStartTime = now
                                strokeStartTime = now  // ✅ record the "spin phase" anchor
                                activePoints = []
                                startSampleLoop()
                            }
                            fingerLocation = value.location
                            fingerIsDown = true
                        }
                        .onEnded { _ in
                            fingerIsDown = false
                            fingerLocation = nil
                            stopSampleLoop()
                            commitStroke()
                        }
                )
            }
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

        // ⏸️ Freeze the canvas angle at stroke end
        let rotationAtLift = angleSince(.distantPast, now: now)

        // 🎯 Undo that rotation from each point
        let renderedPoints = activePoints.map { sample in
            let angleNow = sample.angleAtZero + angleSince(sample.timestamp, now: now)
            let correctedAngle = angleNow - rotationAtLift  // ✅ remove current spin
            return CGPoint(
                x: center.x + sample.radius * cos(correctedAngle.toRadians()),
                y: center.y + sample.radius * sin(correctedAngle.toRadians())
            )
        }

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
}


