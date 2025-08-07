//
//  23-AboutSheet.swift
//  Spindigo
//
//  Created by Alan Metzger on 8/3/25.
//

import SwiftUI

struct AboutSheet: View {
    var body: some View {
        ScrollView {
        VStack(spacing: 20) {
            Text("About Spindigo")
                .font(.system(size: DeviceInfo.isPhone ? 18.0 : 28.0))
                .foregroundStyle(.yellow)
                .bold()
            
            Text("Spindigo is a creative app that lets you create visually stunning animations and spin art.")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)
            
            // Add more info or a link to your privacy policy here
            Text("Spindigo's Privacy Policy can be found at:")
            
            Link("Spindigo's Privacy Policy", destination: URL(string: "https://ramaccts.wixsite.com/exaq-services-llc#spindigo-privacy-policy")!)
                .font(.subheadline)
                .foregroundColor(.blue)
                .underline()
            
            Text("For app support or feedback, please contact alanm@exaqservices.com.")
            
            Spacer()
        }
        .padding()
    }
    }
}
