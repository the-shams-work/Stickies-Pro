//
//  OnboardingView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 16/02/25.
//

import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var hasSeenOnboarding: Bool

    let features: [(icon: String, color: Color, title: String, description: String)] = [
        ("note.text", .blue, "onboarding.feature1.title", "onboarding.feature1.desc"),
        ("list.bullet", .orange, "onboarding.feature2.title", "onboarding.feature2.desc"),
        ("bell.fill", .red, "onboarding.feature3.title", "onboarding.feature3.desc"),
        ("clock.fill", .purple, "onboarding.feature4.title", "onboarding.feature4.desc"),
        ("tray.full.fill", .green, "onboarding.feature5.title", "onboarding.feature5.desc"),
        ("magnifyingglass", .cyan, "onboarding.feature6.title", "onboarding.feature6.desc"),
        ("hand.tap.fill", .indigo, "onboarding.feature7.title", "onboarding.feature7.desc"),
        ("paintpalette.fill", .pink, "onboarding.feature8.title", "onboarding.feature8.desc"),
        ("globe", .teal, "onboarding.feature9.title", "onboarding.feature9.desc")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Title area
            VStack(spacing: 6) {
                Text("onboarding.title")
                    .font(.largeTitle.weight(.bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .padding(.top, 50)
            .padding(.bottom, 30)

            // Feature list
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(0..<features.count, id: \.self) { index in
                        OnboardingFeatureRow(
                            icon: features[index].icon,
                            iconColor: features[index].color,
                            title: LocalizedStringKey(features[index].title),
                            description: LocalizedStringKey(features[index].description)
                        )
                    }
                }
                .padding(.horizontal, 40)
            }

            Spacer(minLength: 20)

            // Get Started button
            Button(action: {
                hasSeenOnboarding = true
            }) {
                Text("onboarding.start")
                    .font(.body.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(themeManager.theme.color)
                    )
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasSeenOnboarding: .constant(false))
    }
}
