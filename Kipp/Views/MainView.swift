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
        if hasSeenOnboarding {
            ContentView(viewModel: viewModel)
        } else {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
    }
}
