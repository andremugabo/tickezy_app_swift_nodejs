//
//  SplashScreen.swift
//  TICKEZY
//
//  Created by M.A on 10/14/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity = 0.0

    var body: some View {
        ZStack {
            if isActive {
                // Main app content
                ContentView()
                    .transition(.opacity)
            } else {
                Color.appBackground
                    .ignoresSafeArea()
                // Splash content
                VStack(spacing: 20) {
                    Image("logo1")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .onAppear {
                            // Animate logo
                            withAnimation(.easeOut(duration: 1.2)) {
                                scale = 1.0
                                opacity = 1.0
                            }
                        }


                }
                .transition(.opacity)
            }
        }
        .onAppear {
            // Keep splash for 3 seconds before showing ContentView
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isActive = true
                }
            }
        }
        .animation(.easeInOut, value: isActive) // Smooth fade transition
    }
}

#Preview {
    SplashScreen()
}
