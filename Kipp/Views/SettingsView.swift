//
//  SettingsView.swift
//  Kipp
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var showRestartAlert = false
    @State private var showResetAlert = false
    @State private var pendingLanguage: AppLanguage?
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(selection: $themeManager.theme) {
                        ForEach(AppTheme.allCases) { theme in
                            HStack {
                                Circle()
                                    .fill(theme.color)
                                    .frame(width: 20, height: 20)
                                Text(LocalizedStringKey(theme.rawValue))
                            }
                            .tag(theme)
                        }
                    } label: {
                        HStack(spacing: 14) {
                            HIGIcon(systemName: "paintpalette.fill", color: .purple)
                            Text("settings.appearance.theme")
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("settings.appearance")
                }
                
                Section {
                    Picker(selection: Binding(
                        get: { pendingLanguage ?? languageManager.language },
                        set: { newLanguage in
                            if newLanguage != languageManager.language {
                                pendingLanguage = newLanguage
                                showRestartAlert = true
                            }
                        }
                    )) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName)
                                .tag(language)
                        }
                    } label: {
                        HStack(spacing: 14) {
                            HIGIcon(systemName: "globe", color: .blue)
                            Text("settings.language.app")
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("settings.language")
                }
                
                Section {
                    Button(role: .destructive, action: {
                        showResetAlert = true
                    }) {
                        HStack(spacing: 14) {
                            HIGIcon(systemName: "arrow.counterclockwise", color: .red)
                            Text("settings.reset_all")
                                .foregroundColor(.red)
                        }
                    }
                    .alert("settings.reset_all.title", isPresented: $showResetAlert) {
                        Button("common.cancel", role: .cancel) { }
                        Button("settings.reset_all.confirm", role: .destructive) {
                            themeManager.theme = .purple
                            if languageManager.language != .system {
                                pendingLanguage = .system
                                showRestartAlert = true
                            }
                        }
                    } message: {
                        Text("settings.reset_all.message")
                    }
                    .tint(.black)
                }
            }
            .navigationTitle("settings.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.theme.color)
                }
            }
            .tint(themeManager.theme.color)
            // The translation keys here will be mapped in the next refactor 
            .alert("settings.restart.title", isPresented: $showRestartAlert) {
                Button("common.cancel", role: .cancel) {
                    pendingLanguage = nil
                }
                Button("settings.restart.confirm", role: .destructive) {
                    if let newLanguage = pendingLanguage {
                        languageManager.language = newLanguage
                        // Force a crash/restart to let iOS reboot the app with the new AppleLanguages
                        exit(0)
                    }
                }
            } message: {
                Text("settings.restart.message")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeManager())
        .environmentObject(LanguageManager())
}
