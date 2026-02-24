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
                Section(header: Text("settings.appearance")) {
                    Picker("settings.appearance.theme", selection: $themeManager.theme) {
                        ForEach(AppTheme.allCases) { theme in
                            HStack {
                                Circle()
                                    .fill(theme.color)
                                    .frame(width: 20, height: 20)
                                Text(LocalizedStringKey(theme.rawValue))
                            }
                            .tag(theme)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section(header: Text("settings.language")) {
                    Picker("settings.language.app", selection: Binding(
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
                    }
                    .pickerStyle(.navigationLink)
                }
                
                Section {
                    Button(role: .destructive, action: {
                        showResetAlert = true
                    }) {
                        Text("settings.reset_all")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .alert("settings.reset_all.title", isPresented: $showResetAlert) {
                        Button("common.cancel", role: .cancel) { }
                        Button("settings.reset_all.confirm", role: .destructive) {
                            // Reset preferences to default values
                            themeManager.theme = .purple
                            
                            // Check if language is not system default, so we can reboot
                            if languageManager.language != .system {
                                pendingLanguage = .system
                                showRestartAlert = true
                            }
                        }
                    } message: {
                        Text("settings.reset_all.message")
                    }
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
