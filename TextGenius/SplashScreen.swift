//
//  SplashScreen.swift
//  TextGenius
//
//  Created by Dev Asheesh Chopra on 05/07/24.
//


import SwiftUI

struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var rotateKeyboard = false
    @State private var removeKeyboard = false
    @State private var circleExpansion = 0.0
    @State private var transitionToSettings = false
    @State private var settingsViewScale = 0.1

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ZStack{
                Circle() // Outermost circle
                    .stroke(Color.white.opacity(0.2), lineWidth: 15)
                    .scaleEffect(circleExpansion >= 3 ? 4 : 1)
                    .opacity(circleExpansion >= 3 ? 0 : 1)
                    .frame(width: 280, height: 280)
                    .animation(.easeOut(duration: 0.5).delay(0.8), value: circleExpansion)
                
                Circle() // Middle circle
                    .stroke(Color.white.opacity(0.4), lineWidth: 22)
                    .scaleEffect(circleExpansion >= 2 ? 3.5 : 1)
                    .opacity(circleExpansion >= 2 ? 0 : 1)
                    .frame(width: 239, height: 239)
                    .animation(.easeOut(duration: 0.5).delay(0.9), value: circleExpansion)
                
                Circle() // Innermost circle
                    .stroke(Color.white.opacity(0.2), lineWidth: 15)
                    .scaleEffect(circleExpansion >= 1 ? 3 : 1)
                    .opacity(circleExpansion >= 1 ? 0 : 1)
                    .frame(width: 200, height: 200)
                    .animation(.easeOut(duration: 0.5).delay(1), value: circleExpansion)
                
                
                if !removeKeyboard {
                    LottieView(name: "keyboard", loopMode: .loop, animationSpeed: 1)
                        .brightness(0.03)
                        .scaleEffect(0.15)
                        .rotationEffect(.degrees(rotateKeyboard ? 360 : 0))
                        .animation(.linear(duration: 0.5), value: rotateKeyboard)
                        .onAppear {
                            withAnimation {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                    rotateKeyboard = true
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.05) {
                                removeKeyboard = true
                            }
                        }
                }
                
            }
            .offset(y: isAnimating ? -10 : 10)
                
                // SettingsView appearance
            if transitionToSettings {
                SettingsView().background()
                    .transition(.opacity.animation(.easeOut))
            }
            
        }
        
        .animation(
            Animation.easeInOut(duration: 2),
            value: isAnimating
        )
        .onAppear {
            isAnimating = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                circleExpansion = 3
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.277) {
                    transitionToSettings = true
                    settingsViewScale = 1
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        
    }
}

#Preview {
    SplashScreenView()
}
