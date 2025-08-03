//
//  22-DrawingGestureModifier.swift
//  Spindigo
//
//  Created by Alan Metzger on 8/3/25.
//

import SwiftUI

struct DrawingGestureModifier: ViewModifier {
    @Binding var fingerIsDown: Bool
    @Binding var fingerLocation: CGPoint?
    @Binding var activePoints: [CanvasView.PolarSample]

    let startSampleLoop: () -> Void
    let stopSampleLoop: () -> Void
    let commitStroke: () -> Void
    let recordStrokeStart: () -> Void

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !fingerIsDown {
                            recordStrokeStart()
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
