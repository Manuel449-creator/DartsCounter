//
//  DartCounterApp.swift
//  DartsCounter
//
//  Created by Manuel Wagner on 28.01.25.
//


import SwiftUI

@main
struct DartCounterApp: App {
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.theme.colorScheme)
        }
    }
}
