//
//  ContentView.swift
//  Spindigo
//
//  Created by Alan Metzger on 7/27/25.
//

import SwiftUI


struct ContentView: View {
    @State private var selectedTab = 0
    @State private var displayFrameRate = 30
    @State private var spinRPM = 36.0
    @State private var clearTrigger = false
    @State private var penSize: CGFloat = 10.0

    var body: some View {
        TabView(selection: $selectedTab) {
            PenView(
                penSize: $penSize,
                displayFrameRate: $displayFrameRate,
                spinRPM: $spinRPM,
                clearTrigger: $clearTrigger,
                isActive: .constant(selectedTab == 0)
            )
            .tabItem {
                Label("Canvas", systemImage: "pencil.tip")
            }
            .tag(0)

//            SpeedSettingsView(
//                displayFrameRate: $displayFrameRate,
//                spinRPM: $spinRPM
//            )
//            .tabItem {
//                Label("Speed", systemImage: "speedometer")
//            }
//            .tag(1)

            SaveView()
                .tabItem {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
            .tag(2)
        }
    }
}

//#Preview {
//    ContentView()
//}


