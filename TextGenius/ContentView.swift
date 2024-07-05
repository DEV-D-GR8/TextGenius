//
//  ContentView.swift
//  TextGenius
//
//  Created by Dev Asheesh Chopra on 27/06/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasLaunchedBefore") var hasLaunchedBefore: Bool = false

    var body: some View {
        if hasLaunchedBefore {
            SplashScreenView()
        } else {
            StartView()
                .onAppear {
                    hasLaunchedBefore = true
                }
        }
        
    }
}


#Preview {
    ContentView()
}
