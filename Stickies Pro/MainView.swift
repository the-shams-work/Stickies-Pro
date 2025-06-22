//
//  MainView.swift
//  Stickies
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

struct MainView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject var viewModel = NotesViewModel()
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasSeenOnboarding")

    var body: some View {
        if hasSeenOnboarding {
            TabView {
                ContentView(viewModel: viewModel)
                    .tabItem {
                        Label("My Notes", systemImage: "note.text")
                    }

                HistoryView(viewModel: viewModel)
                    .tabItem {
                        Label("History", systemImage: "clock")
                    }
            }
            .tint(.purple)
        } else {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }

    }
}
