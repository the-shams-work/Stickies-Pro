//
//  AppTheme.swift
//  Kipp
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case purple = "Purple"
    case blue = "Blue"
    case green = "Green"
    case orange = "Orange"
    case red = "Red"
    case pink = "Pink"
    
    var id: String { self.rawValue }
    
    var color: Color {
        switch self {
        case .purple: return .purple
        case .blue: return .blue
        case .green: return .green
        case .orange: return .orange
        case .red: return .red
        case .pink: return .pink
        }
    }
}
