//
//  LanguageManager.swift
//  Kipp
//

import SwiftUI

class LanguageManager: ObservableObject {
    @AppStorage("selectedAppLanguage") private var selectedLanguageRawValue: String = AppLanguage.system.rawValue
    
    @Published var language: AppLanguage = .system {
        didSet {
            selectedLanguageRawValue = language.rawValue
            setSystemLanguage(language)
        }
    }
    
    init() {
        if let savedLanguage = AppLanguage(rawValue: selectedLanguageRawValue) {
            self.language = savedLanguage
        }
    }
    
    private func setSystemLanguage(_ appLanguage: AppLanguage) {
        if appLanguage == .system {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.set([appLanguage.rawValue], forKey: "AppleLanguages")
        }
        UserDefaults.standard.synchronize()
    }
}
