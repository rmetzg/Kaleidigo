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
    
}


