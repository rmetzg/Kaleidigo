//
//  23-AboutSheet.swift
//  Kaleidigo
//
//  Created by Alan Metzger on 8/3/25.
//

import SwiftUI

struct AboutSheet: View {
    var body: some View {

        VStack(spacing: 20) {
            Text("About Kaleidigo")
                .font(.system(size: DeviceInfo.isPhone ? 18.0 : 28.0))
                .foregroundStyle(.yellow)
                .bold()
            
            ScrollView {
            
            Text("Kaleidigo is a creative app that lets you create visually stunning animations, spin art, and mandalas. Here are some brief instructions on how to take advantage of every feature.")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)
            
            Text(" ")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)
            
            Text("1) Controls for iPad and iPhone are located in slightly different ways. iPad has most controls on the main screen, while iPhone relies on more popup menus.")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)
            
            Text(" ")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)
            
            Text("2) You can set the Speed of the rotation of the canvas with the 'Speed' slider or up/down buttons.")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)
            
            Text(" ")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)

            
            Text("3) Stop the canvas easily by clicking the 'Zero Spd' button. This is useful if you are drawing aniations and need a non-moving canvas.")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)
                 
            Text(" ")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)
            
            Text("4) You can also set Frame Rate with the other slider and up/down controls. Frame Rate is the number of times per second that the system redraws the screen.")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)
                 
             Text(" ")
                 .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                 .multilineTextAlignment(.center)
             
             Text("5) Animation is created through certain combinations of Speed and Frame Rate. A good place to start is to set a high rate of speed and a low number of frames per second (say 10%). For example, 240 RPM and 12 frames/second often produces a jittering result. Move the frames per second up to 13 or down to 11 and you will start to notice the 'wagon wheel' effect, where the canvas appears to be rotating slowly.")
                 .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                 .multilineTextAlignment(.center)
                 
             Text(" ")
                 .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                 .multilineTextAlignment(.center)
             
             Text("6) Use the 'Animate' button to quickly select some of the possible animation combinations. Six animation combinations have been pre-loaded and you cycle through them each time you push the button. The seventh press will bring you back to your original speed and frame rate. Or you can press 'Zero Spd' at any time to stop the Animate button. When animating, the 'Animate' button has a glow effect turned on.")
                 .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                 .multilineTextAlignment(.center)
                 
             Text(" ")
                 .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                 .multilineTextAlignment(.center)
             
             Text("7) How do you make images appear like they are moving in 'Animate' mode? One way is to draw the same image repeatedly around the circle of the canvas and then make slight changes to it (the eraser comes in handy here). Go to the App Store and look at some of the images for the app and notice how drawing the same things slightly different yields motion when animated. To make something wave back and forth, draw it as  straight on the top image, slightly moved on the next image, and so on until you return to the top.")
                 .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                 .multilineTextAlignment(.center)
                 
             Text(" ")
                 .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                 .multilineTextAlignment(.center)
             
             Text("8) You can do this with an imported image, too. Click 'Load' and then select 'Load as Pie Slices'. Then, load an image from your Photos library. You will get a canvas with six slices of the image. Draw items slightly different on each of the six images and then 'Animate'.")
                 .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                 .multilineTextAlignment(.center)
                 
             Text(" ")
                 .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                 .multilineTextAlignment(.center)
             
             Text("9) Finally, for one of the most interesting features of the app, create a mandala. Load an image using 'Load as Pie Slices' and then go to your canvas to see the six pie slices. Immediately 'Save' that image to your Photos app. Now, go to 'Load' again, select 'Load as Pie Slices' and load the image you just saved (pie slices). Now you have a canvas of 6 slices, each containing 6 slices--for a total of 36 images. Continue this procedure and watch how quickly a complex image is formed. Save them, print them, make wallpaper, or start a quilt!")
                 .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                 .multilineTextAlignment(.center)
                
            Text(" ")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)
            

            Text("Kaleidigo's Privacy Policy can be found at:")
            
            Link("Kaleidigo's Privacy Policy", destination: URL(string: "https://ramaccts.wixsite.com/exaq-services-llc#kaleidigo-privacy-policy")!)
                .font(.subheadline)
                .foregroundColor(.blue)
                .underline()
                
            Text(" ")
                .font(.system(size: DeviceInfo.isPhone ? 13.0 : 18.0))
                .multilineTextAlignment(.center)
            
            Text("For app support or feedback, please contact alanm@exaqservices.com.")
            
            Spacer()
        }
        .padding()
    }
    }
}
