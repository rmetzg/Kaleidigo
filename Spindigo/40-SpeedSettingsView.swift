//
//  SpeedSettingsView.swift
//  Spindigo
//
//  Created by Alan Metzger on 7/28/25.
//

//import SwiftUI
//
//struct SpeedSettingsView: View {
//    @Binding var displayFrameRate: Int
//    @Binding var spinRPM: Double
//
//    var body: some View {
//        VStack(spacing: 30) {
//            VStack {
//                Text("Frame Rate: \(displayFrameRate) FPS")
//                    .font(.headline)
//                Slider(value: Binding(
//                    get: { Double(displayFrameRate) },
//                    set: { displayFrameRate = Int($0) }
//                ), in: 5...120, step: 1)
//                    .padding(.horizontal)
//            }
//
//            VStack {
//                Text("Spin Speed: \(Int(spinRPM)) RPM")
//                    .font(.headline)
//                Slider(value: $spinRPM, in: -120...120, step: 1)
//                    .padding(.horizontal)
//            }
//        }
//        .padding(.top)
//    }
//}
