//
//  ExtensionsEtc.swift
//  Spindigo
//
//  Created by Alan Metzger on 7/28/25.
//

import SwiftUI


struct OrbitingPath {
    let points: [CGPoint]
    let creationTime: Date
    let color: Color
    let lineWidth: CGFloat
}

extension Double {
    func toRadians() -> CGFloat { CGFloat(self * .pi / 180) }
    func toDegrees() -> Double { self * 180 / .pi }
}

extension View {
    func controlMiniButtonStyle() -> some View {
        self
            .font(.largeTitle)
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
    
}

enum QuickPenColor: String, CaseIterable, Identifiable {
    case white, black, blue, red, yellow, green

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .white: return .white
        case .black: return .black
        case .blue: return .blue
        case .red: return .red
        case .yellow: return .yellow
        case .green: return .green
        }
    }

    var label: String {
        rawValue.capitalized
    }
}

extension CGFloat {
    func toRadians() -> CGFloat {
        return self * .pi / 180
    }
}

enum QuickBackgroundColor: String, CaseIterable, Identifiable {
    case white, black, blue, red, yellow, green

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .white: return .white
        case .black: return .black
        case .blue: return .blue
        case .red: return .red
        case .yellow: return .yellow
        case .green: return .green
        }
    }

    var label: String {
        rawValue.capitalized
    }
}
