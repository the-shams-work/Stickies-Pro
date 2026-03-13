//
//  MainView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

struct MainView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject var viewModel = NotesViewModel()

    var body: some View {
        ContentView(viewModel: viewModel)
            .sheet(isPresented: Binding(
                get: { !hasSeenOnboarding },
                set: { if !$0 { hasSeenOnboarding = true } }
            )) {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                    .interactiveDismissDisabled()
            }
    }
}
