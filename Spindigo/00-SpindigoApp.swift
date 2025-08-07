//
//  SpindigoApp.swift
//  Spindigo
//
//  Created by Alan Metzger on 7/27/25.
//

import SwiftUI


@main
struct SpindigoApp: App {
    
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreenView {
                        // Completion handler called when splash is done
                        withAnimation {
                            showSplash = false
                        }
                    }
                } else {
                    MainView()
                }
            }
        }
    }
}
