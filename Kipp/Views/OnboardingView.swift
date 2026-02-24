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

    let onboardingData: [(image: String, title: String, description: String)] = [
        ("note.text", "onboarding.feature1.title", "onboarding.feature1.desc"),
        ("list.bullet", "onboarding.feature2.title", "onboarding.feature2.desc"),
        ("bell.fill", "onboarding.feature3.title", "onboarding.feature3.desc"),
        ("clock.fill", "onboarding.feature4.title", "onboarding.feature4.desc"),
        ("tray.full.fill", "onboarding.feature5.title", "onboarding.feature5.desc"),
        ("magnifyingglass", "onboarding.feature6.title", "onboarding.feature6.desc"),
        ("hand.tap.fill", "onboarding.feature7.title", "onboarding.feature7.desc"),
        ("paintpalette.fill", "onboarding.feature8.title", "onboarding.feature8.desc"),
        ("globe", "onboarding.feature9.title", "onboarding.feature9.desc")
    ]

    var body: some View {
        VStack {
            Text("onboarding.title")
                .font(.largeTitle.bold())
                .foregroundColor(themeManager.theme.color)
                .padding(.top, 30)
                .padding(.bottom, 10)

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(0..<onboardingData.count, id: \.self) { index in
                        HStack(alignment: .top, spacing: 15) {
                            Image(systemName: onboardingData[index].image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45)
                                .foregroundColor(themeManager.theme.color)
                                .padding(.top, 8)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizedStringKey(onboardingData[index].title))
                                    .font(.subheadline.bold())
                                    .foregroundColor(.black)

                                Text(LocalizedStringKey(onboardingData[index].description))
                                    .font(.footnote)
                                    .foregroundColor(.black.opacity(0.7))
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 30)
                    }
                }
                .padding(.top, 10)
            }

            Spacer()

            Button(action: {
                hasSeenOnboarding = true
            }) {
                Text("onboarding.start")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(themeManager.theme.color)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .padding(.horizontal, 40)
            }
            .padding(.bottom, 30)
        }
        .background(Color.white.ignoresSafeArea())
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasSeenOnboarding: .constant(false))
    }
}
