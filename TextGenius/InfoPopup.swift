//
//  InfoPopup.swift
//  TextGenius
//
//  Created by Dev Asheesh Chopra on 04/07/24.
//

import SwiftUI

struct InfoPopup: View {
    @Binding var showingPopup: Bool
    
    var body: some View {
        VStack {
            Text("Allow Full Access is required to enable all features.")
                .padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 20)
        .overlay(
            Button(action: {
                showingPopup = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .padding(.top, 10)
            .padding(.trailing, 10)
            , alignment: .topTrailing
        )
    }
}

