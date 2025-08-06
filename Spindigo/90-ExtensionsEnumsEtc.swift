//
//  ExtensionsEtc.swift
//  Spindigo
//
//  Created by Alan Metzger on 7/28/25.
//

import SwiftUI

struct DeviceInfo {
    static var isPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }

    static var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
}

enum DeviceScaling {
    static let screenWidth = UIScreen.main.bounds.width
    static let baseWidth: CGFloat = 744  // iPad Mini 7 width in portrait
    static var scaleFactor: CGFloat {
        min(1.0, screenWidth / baseWidth)
    }
}

struct OrbitingPath {
    let points: [CGPoint]
    let creationTime: Date
    let color: Color
    let lineWidth: CGFloat
}

struct RampingButton: View {
    let label: String
    let onStep: () -> Void
    let onLongPressStep: () -> Void

    @State private var isPressed = false
    @State private var timer: Timer?

    var body: some View {
        Text(label)
            .font(.custom("Noteworthy", size: 32))
            .foregroundStyle(.white)
            .frame(minWidth: 60, minHeight: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.spindigoAccent)
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            onStep()
                            startTimer()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        stopTimer()
                    }
            )
            .onDisappear {
                stopTimer()
            }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if isPressed {
                onLongPressStep()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension Double {
    func toRadians() -> CGFloat { CGFloat(self * .pi / 180) }
    func toDegrees() -> Double { self * 180 / .pi }
}

extension View {
    func controlMiniButtonStyle() -> some View {
        self
            .font(.system(size: 34))
                    .foregroundStyle(.white)
                    .font(.custom("Noteworthy", size: 32))
                    .frame(minWidth: 60, minHeight: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.spindigoAccent)
                        )
    }
}

extension Color {
    static let spindigoAccent = Color(red: 0x01 / 255.0, green: 0xC7 / 255.0, blue: 0xFC / 255.0)
    
    static let darkIndigo = Color(red: 0x2A / 255.0, green: 0x0E / 255.0, blue: 0x5C / 255.0)
    
    static let spindigoOrange = Color(red: 0xFF / 255.0, green: 0x6A / 255.0, blue: 0x00 / 255.0)
    
    static let spindigoYellow = Color(red: 0xFF / 255.0, green: 0xF9 / 255.0, blue: 0x94 / 255.0)
    
    static let darkGreen = Color(red: 0x38 / 255.0, green: 0x95 / 255.0, blue: 0x1A / 255.0)
    
}

enum QuickPenColor: String, CaseIterable, Identifiable {
    case black, white, red, blue, green, yellow, purple, eraser

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .black: return .black
        case .white: return .white
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .purple: return .purple
        case .eraser: return .clear  // Not used for drawing color directly
        }
    }

    var label: String {
        self == .eraser ? "Eraser" : rawValue.capitalized
    }


    var isEraser: Bool {
        self == .eraser
    }
}

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * .pi / 180
    }
}

enum QuickBackgroundColor: String, CaseIterable, Identifiable {
    case white, black, blue, red, yellow, green, purple

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .white: return .white
        case .black: return .black
        case .blue: return .blue
        case .red: return .red
        case .yellow: return .yellow
        case .green: return .green
        case .purple: return .purple
        }
    }

    var label: String {
        rawValue.capitalized
    }
}
