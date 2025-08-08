//
//  CanvasDrawingArea.swift
//  Kaleidigo
//
//  Created by Alan Metzger on 8/3/25.
//

import SwiftUI

struct CanvasDrawingArea: View {
    @Binding var canvasSize: CGSize
    @Binding var canvasImage: UIImage?
    @Binding var activePoints: [CanvasView.PolarSample]
    @Binding var fingerIsDown: Bool
    @Binding var fingerLocation: CGPoint?
    @Binding var currentTime: Date
    @Binding var penEraser: Bool

    let penSize: CGFloat
    let penColor: Color
    let canvasBackgroundColor: Color
    let spinRPM: Double
    

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let activeDiameter = min(geo.size.width, geo.size.height) - 10

            ZStack {
                Color.darkIndigo.ignoresSafeArea()

                ZStack {
                    Circle()
                        .fill(canvasBackgroundColor)
                        .frame(width: activeDiameter, height: activeDiameter)
                        .position(center)

                    if let image = canvasImage {
                        Image(uiImage: image)
                            .resizable()
                            .frame(width: activeDiameter, height: activeDiameter)
                            .rotationEffect(.degrees(angleSince(.distantPast, now: currentTime)))
                            .position(center)
                            .mask(
                                Circle()
                                    .frame(width: activeDiameter, height: activeDiameter)
                            )
                    }

                    Path { path in
                        let radius = activeDiameter / 2 * 0.5
                        for i in 0..<8 {
                            let angle = CGFloat(i) * .pi / 4
                            let dx = radius * cos(angle)
                            let dy = radius * sin(angle)
                            path.move(to: center)
                            path.addLine(to: CGPoint(x: center.x + dx, y: center.y + dy))
                        }
                    }
                    .stroke(Color.gray.opacity(0.5), lineWidth: 0.5)
                    .rotationEffect(.degrees(angleSince(.distantPast, now: currentTime)))

                    Circle()
                        .fill(Color.black)
                        .frame(width: 5, height: 5)
                        .position(center)

                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                        .frame(width: activeDiameter, height: activeDiameter)
                        .position(center)

                    if fingerIsDown {
                        Path { path in
                            for (index, polar) in activePoints.enumerated() {
                                let rotatedAngle = polar.angleAtZero + angleSince(polar.timestamp, now: currentTime)
                                let point = CGPoint(
                                    x: center.x + polar.radius * cos(rotatedAngle.toRadians()),
                                    y: center.y + polar.radius * sin(rotatedAngle.toRadians())
                                )
                                if index == 0 {
                                    path.move(to: point)
                                } else {
                                    path.addLine(to: point)
                                }
                            }
                        }
                        .stroke(penEraser ? Color.gray.opacity(0.5) : penColor.opacity(0.5), lineWidth: penSize)
                        .mask(
                            Circle()
                                .frame(width: activeDiameter, height: activeDiameter)
                                .position(center)
                        )
                    }
                }
            }
            .onAppear {
                canvasSize = geo.size
            }
        }
    }

    private func angleSince(_ start: Date, now: Date) -> Double {
        let elapsed = now.timeIntervalSince(start)
        let degreesPerSecond = spinRPM * 360.0 / 60.0
        return elapsed * degreesPerSecond
    }
}
