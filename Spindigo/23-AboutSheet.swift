//
//  23-AboutSheet.swift
//  Spindigo
//
//  Created by Alan Metzger on 8/3/25.
//

import SwiftUI

struct AboutSheet: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Spindigo")
                .font(.largeTitle.bold())
            Text("""
                 Version 1.0

                 Created by Alan Metzger

                 Spindigo lets you draw on a spinning canvas with dynamic control of speed and frame rate.
                 """)
                .multilineTextAlignment(.center)
                .padding()

            Button("Close") {
                isPresented = false
            }
            .padding()
            .background(Color.darkIndigo)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
