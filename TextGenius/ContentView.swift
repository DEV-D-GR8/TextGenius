//
//  ContentView.swift
//  TextGenius
//
//  Created by Dev Asheesh Chopra on 27/06/24.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasLaunchedBefore", store: UserDefaults(suiteName: "group.dev-d-gr8.TextGenius")) var hasLaunchedBefore: Bool = false

    var body: some View {
        if hasLaunchedBefore {
            SplashScreenView()
        } else {
            StartView()
        }
        
    }
}


#Preview {
    ContentView()
}
