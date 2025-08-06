//
//  35-SpeedPopupSheet.swift
//  Spindigo
//
//  Created by Alan Metzger on 8/5/25.
//

import SwiftUI

struct SpeedPopupSheet: View {
    @Binding var spinRPM: Double
    @Binding var displayFrameRate: Int
    var cancelAnimation: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Speed & Frame Rate")
                .font(.title3)
                .foregroundStyle(.yellow)
                .bold()
                .padding(.bottom, 8)

            VStack(spacing: 12) {
                HStack {
                    Text("Speed: ")
                        .font(.subheadline)
                    Text(" \(Int(spinRPM)) ")
                        .font(.system(size: 24))
                        .bold()
                        .background(.white)
                        .foregroundStyle(Color.darkGreen)
                    Text(" RPM")
                        .font(.subheadline)
                }
                .padding(.bottom, 8)
                
                Slider(value: Binding(
                    get: { spinRPM },
                    set: {
                        cancelAnimation()
                        spinRPM = $0
                    }
                ), in: -240...240, step: 1)
                .padding(.bottom, 8)
                .padding(.horizontal, 10)

                HStack(spacing: 20) {
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
                .padding(.bottom, 8)
            }
            
            HStack {
                Spacer()
                    .frame(width: 16)
                Rectangle()
                    .frame(height: 6)
                    .foregroundColor(.indigo.opacity(0.8))
                Spacer()
                    .frame(width: 16)
            }

            VStack(spacing: 12) {
                
                HStack {
                    Text("Frame Rate: ")
                    .font(.subheadline)
                Text(" \(displayFrameRate) ")
                    .font(.system(size: 24))
                    .bold()
                    .background(.white)
                    .foregroundStyle(Color.blue)
                Text(" /sec")
                    .font(.subheadline)
                }
                .padding(.bottom, 8)
                
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
                .padding(.bottom, 8)
                .padding(.horizontal, 10)

                HStack(spacing: 20) {
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
                .padding(.bottom, 8)
            }
        }
        
    }
}
