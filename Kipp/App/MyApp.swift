//
//  MyApp.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import UIKit

@main
struct MyApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    
    // Global Managers
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var languageManager = LanguageManager()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(themeManager)
                .environmentObject(languageManager)
                // Force layout update when language changes
                .id(languageManager.language.rawValue)
                .environment(\.locale, languageManager.language.locale ?? Locale.current)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }
}

