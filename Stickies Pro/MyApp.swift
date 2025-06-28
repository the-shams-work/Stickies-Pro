//
//  MyApp.swift
//  Stickies Pro
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import UIKit

@main
struct MyApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            MainView()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }
}

