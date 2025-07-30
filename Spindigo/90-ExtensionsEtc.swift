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
