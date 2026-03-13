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
        ("paintpalette.fill", .pink, "onboarding.feature8.title", "onboarding.feature8.desc"),
        ("globe", .teal, "onboarding.feature9.title", "onboarding.feature9.desc")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Scrollable Content
            ScrollView {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 60)

                    if let appIcon = Bundle.main.appIcon {
                        Image(uiImage: appIcon)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .padding(.bottom, 30)
                    }

                    Text("onboarding.title")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.bottom, 40)

                    // Features List
                    VStack(alignment: .leading, spacing: 28) {
                        ForEach(0..<features.count, id: \.self) { index in
                            OnboardingFeatureRow(
                                icon: features[index].icon,
                                iconColor: features[index].color,
                                title: LocalizedStringKey(features[index].title),
                                description: LocalizedStringKey(features[index].description)
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 40)
                        .padding(.bottom, 20)
                }
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)

            // Fixed Continue Button
            VStack(spacing: 0) {
                Button(action: {
                    hasSeenOnboarding = true
                }) {
                    Text("onboarding.start")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(themeManager.theme.color)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 34)
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasSeenOnboarding: .constant(false))
    }
}

extension Bundle {
    var appIcon: UIImage? {
        if let icons = infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let files = primary["CFBundleIconFiles"] as? [String],
           let icon = files.last {
            return UIImage(named: icon)
        }
        return nil
    }
}
