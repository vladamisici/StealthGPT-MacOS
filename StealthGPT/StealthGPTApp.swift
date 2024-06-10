//
//  StealthGPTApp.swift
//  StealthGPT
//
//  Created by Vlada Misici on 10.06.2024.
//

import SwiftUI

@main
struct StealthGPTApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 600, height: 400) // Fixed window size
                .background(CircleAnimationView())
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
}
