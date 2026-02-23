//
//  ThemeManager.swift
//  Kipp
//

import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("selectedAppTheme") private var selectedThemeRawValue: String = AppTheme.purple.rawValue
    
    @Published var theme: AppTheme = .purple {
        didSet {
            selectedThemeRawValue = theme.rawValue
        }
    }
    
    init() {
        if let savedTheme = AppTheme(rawValue: selectedThemeRawValue) {
            self.theme = savedTheme
        }
    }
}
