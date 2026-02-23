//
//  AppLanguage.swift
//  Kipp
//

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case system = "system"
    case spanish = "es"
    case french = "fr"
    case hindi = "hi"
    case chinese = "zh-Hans"
    case german = "de"
    case japanese = "ja"
    case italian = "it"
    case korean = "ko"
    case russian = "ru"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .system: return String(localized: "System Default")
        case .spanish: return "Español"
        case .french: return "Français"
        case .hindi: return "हिंदी"
        case .chinese: return "中文"
        case .german: return "Deutsch"
        case .japanese: return "日本語"
        case .italian: return "Italiano"
        case .korean: return "한국어"
        case .russian: return "Русский"
        }
    }
    
    var locale: Locale? {
        if self == .system {
            return nil
        }
        return Locale(identifier: self.rawValue)
    }
}
