//
//  InstructionView.swift
//  TextGenius
//
//  Created by Dev Asheesh Chopra on 03/07/24.
//

import SwiftUI

struct InstructionView: View {
    @Binding var showingPopup: Bool
    @State private var navigateToNextPage = false
    @State private var textOpacity: Double = 0.0
    @State private var animate: Bool = true
    var body: some View {
        NavigationView {
            ZStack{
                Color.teal.ignoresSafeArea()
                VStack {
                    Text("Enable SmartText")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    VStack(spacing: 20) {
                        InstructionStep(number: "1", text: "Go to Settings", showingPopup: $showingPopup, animate: $animate)
                        InstructionStep(number: "2", text: "TextGenius", showSettingsButton: true, showingPopup: $showingPopup, animate: $animate)
                        InstructionStep(number: "3", text: "Keyboards", showingPopup: $showingPopup, animate: $animate)
                        InstructionStep(number: "4", text: "Enable TextGenius-SmartText", showingPopup: $showingPopup, animate: $animate)
                        InstructionStep(number: "5", text: "Allow Full Access", showInfoIcon: true, showingPopup: $showingPopup, animate: $animate)
                        InstructionStep(number: "6", text: "Customise keyboard settings", showingPopup: $showingPopup, animate: $animate)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    Spacer()
                    
                    Button("Continue") {
                        navigateToNextPage = true // Trigger navigation on button press
                    }
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue.opacity(textOpacity))
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    .onAppear {
                        withAnimation(.easeIn(duration: 2).delay(7*0.3)) {
                            textOpacity = 1.0
                        }
                    }
                    
                    
                    Text("By installing, you are agreeing to TextGenius' Terms of Service and Privacy Policy")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    NavigationLink(destination: SettingsView(), isActive: $navigateToNextPage) {
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure full screen coverage
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
                .blur(radius: showingPopup ? 3 : 0)
                .overlay(
                    // Popup Overlay
                    Group {
                        if showingPopup {
                            InfoPopup(showingPopup: $showingPopup)
                        }
                    }
                )
            }
            .navigationBarHidden(true)
        }
        
        
    }
}


#Preview {
    InstructionView(showingPopup: Binding.constant(false))
}
