//
//  InstructionStep.swift
//  TextGenius
//
//  Created by Dev Asheesh Chopra on 04/07/24.
//

import SwiftUI

struct InstructionStep: View {
    var number: String
    var text: String
    var showInfoIcon: Bool = false
    var showSettingsButton: Bool = false
    @State private var textOpacity: Double = 0.0
    @Binding var showingPopup: Bool
    @Binding var animate: Bool
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(animate ? textOpacity : 1))
                .frame(width: 30, height: 30)
                .overlay(Text(number).foregroundColor(.white))
            
            Text(text)
                .multilineTextAlignment(.leading)
                .padding()
                .foregroundColor(.black)
                .opacity(animate ? textOpacity : 1)
                .onAppear {
                    if animate {
                        withAnimation(.easeIn(duration: 2).delay(Double(number)!*0.3)) {
                            textOpacity = 1.0
                        }
                    }
                }
            
            Spacer()
            
            if showInfoIcon {
                Button(action: {
                    showingPopup.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue.opacity(animate ? textOpacity : 1))
                }
            }
            
            if showSettingsButton {
                Button("Open Settings") {
                    openSettings()
                }
                .foregroundColor(.blue.opacity(animate ? textOpacity : 1))
            }
        }
    }
}

private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url)
}

