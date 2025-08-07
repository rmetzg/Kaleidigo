//
//  SplashScreen.swift
//  Spindigo
//
//  Created by Alan Metzger on 8/6/25.
//

import SwiftUI

// MARK: - SplashScreenView
struct SplashScreenView: View {
    @State private var opacity = 0.0
    var onFinish: () -> Void  // New callback
    
    var body: some View {
        VStack {
            Image("SplashIcon") // Your app icon in Assets
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200, maxHeight: 200)
            
            Text("Spindigo")
                .font(.title)
                .foregroundColor(.black)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea()) // Full screen background
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                opacity = 1.0
            }
            
            // Fade out and trigger callback
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 1.0)) {
                    opacity = 0.0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onFinish()
                }
            }
        }
    }
}

