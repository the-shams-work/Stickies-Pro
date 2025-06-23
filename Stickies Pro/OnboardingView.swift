//
//  OnboardingView.swift
//  Stickies
//
//  Created by Shams Tabrej Alam on 16/02/25.
//

//import SwiftUI
//
//struct OnboardingView: View {
//    @State private var currentPage = 0
//    @Binding var showOnboarding: Bool
//
//    let onboardingData: [(image: String, title: String, description: String)] = [
//        ("note.text", "Create Sticky Notes", "Easily add text, images, audio, and videos."),
//        ("list.bullet", "Organize & Sort", "Categorize notes and sort by title, date, or category."),
//        ("bell.fill", "Smart Reminders", "Set reminders to never forget important tasks."),
//        ("clock.fill", "Auto-Delete", "Notes will be automatically deleted after the end date."),
//        ("tray.full.fill", "History", "Keep track of completed notes."),
//        ("magnifyingglass", "Intuitive Search", "Find notes easily with our smart search bar."),
//        ("hand.tap.fill", "Gesture Controls", "Long-press notes to edit, delete and do much more.")
//    ]
//
//    var body: some View {
//        VStack {
//            HStack {
//                Spacer()
//                Button(action: { showOnboarding = true }) {
//                    Text("Skip")
//                        .foregroundColor(.gray)
//                        .font(.system(size: 16, weight: .medium))
//                }
//                .padding(.trailing, 20)
//                .padding(.top, 10)
//            }
//
//            TabView(selection: $currentPage) {
//                ForEach(0..<onboardingData.count, id: \.self) { index in
//                    VStack(spacing: 20) {
//                        Image(systemName: onboardingData[index].image)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 100, height: 100)
//                            .foregroundColor(.purple)
//
//                        Text(onboardingData[index].title)
//                            .font(.title.bold())
//                            .foregroundColor(.black)
//
//                        Text(onboardingData[index].description)
//                            .font(.body)
//                            .foregroundColor(.black.opacity(0.8))
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal, 30)
//                    }
//                    .tag(index)
//                }
//            }
//            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
//            .indexViewStyle(.page(backgroundDisplayMode: .always))
//
//            Spacer()
//
//            Button(action: {
//                if currentPage < onboardingData.count - 1 {
//                    withAnimation {
//                        currentPage += 1
//                    }
//                } else {
//                    showOnboarding = true
//                }
//            }) {
//                Text(currentPage == onboardingData.count - 1 ? "Get Started" : "Next")
//                    .font(.system(size: 18, weight: .bold))
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.purple)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
//                    .padding(.horizontal, 40)
//            }
//            .padding(.bottom, 30)
//        }
//        .background(Color.white.ignoresSafeArea())
//    }
//}




import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool

    let onboardingData: [(image: String, title: String, description: String)] = [
        ("note.text", "Create Sticky Notes", "Easily add text, images, audio, and videos."),
        ("list.bullet", "Organize & Sort", "Categorize notes and sort by title, date, or category."),
        ("bell.fill", "Smart Reminders", "Set reminders to never forget important tasks."),
        ("clock.fill", "Auto-Delete", "Notes will be automatically deleted after the end date."),
        ("tray.full.fill", "History", "Keep track of completed notes."),
        ("magnifyingglass", "Intuitive Search", "Find notes easily with our smart search bar."),
        ("hand.tap.fill", "Gesture Controls", "Long-press notes to edit, delete and do much more.")
    ]

    var body: some View {
        VStack {
            Text("Welcome to Stikies Pro")
                .font(.largeTitle.bold())
                .foregroundColor(.purple)
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
                                .foregroundColor(.purple)
                                .padding(.top, 8)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(onboardingData[index].title)
                                    .font(.subheadline.bold())
                                    .foregroundColor(.black)

                                Text(onboardingData[index].description)
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
                Text("Get Started")
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
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
