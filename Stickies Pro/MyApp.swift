//
//  MyApp.swift
//  Stickies
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

@main
struct MyApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

