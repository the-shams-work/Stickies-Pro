//
//  StickyNote.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

enum NoteCategory: Identifiable, Codable, Equatable, Hashable {
    case todo, journal, ideas, study, finance, work, goals, important, projects, music, books, movies, art, writing, diet, mental, health, travel, memories, urgent, home, shopping
    case custom(String)

    static var allCases: [NoteCategory] {
        return [
            .todo, .journal, .ideas, .study, .finance, .work, .goals, .important, .projects, .music, .books, .movies, .art, .writing, .diet, .mental, .health, .travel, .memories, .urgent, .home, .shopping
        ]
    }

    var rawValue: String {
        switch self {
        case .todo: return "To Do"
        case .journal: return "Journals"
        case .ideas: return "Ideas"
        case .study: return "Study Notes"
        case .finance: return "Finance"
        case .work: return "Work Notes"
        case .goals: return "Goals"
        case .important: return "Important"
        case .projects: return "Projects"
        case .music: return "Music & Lyrics"
        case .books: return "Book Notes"
        case .movies: return "Movie Reviews"
        case .art: return "Art & Design"
        case .writing: return "Writing & Blog"
        case .diet: return "Diet & Fitness"
        case .mental: return "Mental Wellness"
        case .health: return "Health Records"
        case .travel: return "Travel Plans"
        case .memories: return "Memories"
        case .urgent: return "Urgent"
        case .home: return "Home & Family"
        case .shopping: return "Shopping List"
        case .custom(let value): return value
        }
    }

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .todo: return "checklist"
        case .journal: return "book"
        case .ideas: return "lightbulb"
        case .study: return "graduationcap"
        case .finance: return "dollarsign.circle"
        case .work: return "briefcase"
        case .goals: return "target"
        case .important: return "exclamationmark.triangle"
        case .projects: return "chart.bar"
        case .music: return "music.note"
        case .books: return "text.book.closed"
        case .movies: return "film"
        case .art: return "paintbrush"
        case .writing: return "pencil"
        case .diet: return "leaf"
        case .mental: return "brain.head.profile"
        case .health: return "cross.case"
        case .travel: return "airplane"
        case .memories: return "photo"
        case .urgent: return "exclamationmark.octagon"
        case .home: return "house"
        case .shopping: return "cart"
        case .custom: return "tag"
        }
    }

    var iconColor: Color {
        switch self {
        case .todo: return .blue
        case .journal: return .purple
        case .ideas: return .yellow
        case .study: return .indigo
        case .finance: return .green
        case .work: return .blue
        case .goals: return .orange
        case .important: return .red
        case .projects: return .teal
        case .music: return .pink
        case .books: return .brown
        case .movies: return .purple
        case .art: return .mint
        case .writing: return .indigo
        case .diet: return .green
        case .mental: return .cyan
        case .health: return .red
        case .travel: return .blue
        case .memories: return .pink
        case .urgent: return .red
        case .home: return .orange
        case .shopping: return .green
        case .custom: return .gray
        }
    }

    var subtitle: String {
        switch self {
        case .todo: return "Tasks and to-do items"
        case .journal: return "Daily journal entries"
        case .ideas: return "Creative ideas and thoughts"
        case .study: return "Study notes and materials"
        case .finance: return "Financial records and budgets"
        case .work: return "Work-related notes"
        case .goals: return "Personal and professional goals"
        case .important: return "High-importance items"
        case .projects: return "Project planning and tracking"
        case .music: return "Songs, lyrics, and playlists"
        case .books: return "Book summaries and reviews"
        case .movies: return "Movie reviews and watchlist"
        case .art: return "Art ideas and design notes"
        case .writing: return "Blog posts and drafts"
        case .diet: return "Diet plans and fitness logs"
        case .mental: return "Mindfulness and wellness"
        case .health: return "Medical records and notes"
        case .travel: return "Travel plans and itineraries"
        case .memories: return "Special moments and memories"
        case .urgent: return "Time-sensitive items"
        case .home: return "Household and family notes"
        case .shopping: return "Shopping lists and wishlists"
        case .custom: return "Your custom category"
        }
    }

    static func == (lhs: NoteCategory, rhs: NoteCategory) -> Bool {
        switch (lhs, rhs) {
        case let (.custom(a), .custom(b)): return a == b
        case (.custom, _), (_, .custom): return false
        default: return lhs.rawValue == rhs.rawValue
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .custom(let value):
            hasher.combine("custom")
            hasher.combine(value)
        default:
            hasher.combine(rawValue)
        }
    }
}

enum Priority: String, CaseIterable, Identifiable, Codable, Equatable, Hashable {
    case none = "None"
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var id: String { self.rawValue }
    
    var sortOrder: Int {
        switch self {
        case .none: return -1
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        }
    }
    
    var systemImage: String {
        switch self {
        case .none:
            return "minus.circle"
        case .low:
            return "arrow.down.circle"
        case .medium:
            return "minus.circle"
        case .high:
            return "arrow.up.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .none:
            return .gray
        case .low:
            return .green
        case .medium:
            return .blue
        case .high:
            return .orange
        }
    }

    var iconColor: Color {
        switch self {
        case .none: return .gray
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }

    var flagIcon: String {
        switch self {
        case .none: return "minus"
        case .low: return "flag.fill"
        case .medium: return "flag.fill"
        case .high: return "flag.fill"
        }
    }

    var subtitle: String {
        switch self {
        case .none: return "No priority assigned"
        case .low: return "Can wait, no rush"
        case .medium: return "Should be addressed soon"
        case .high: return "Needs immediate attention"
        }
    }
}

enum ReminderRepeat: String, CaseIterable, Codable, Identifiable, Equatable, Hashable {
    case never = "Never"
    case daily = "Every Day"
    case weekly = "Every Week"
    case monthly = "Every Month"
    case yearly = "Every Year"
    // case custom = "Custom" // For future advanced support

    var id: String { self.rawValue }
}

// MARK: - Background Style

enum NoteBackgroundStyle: String, CaseIterable, Identifiable, Codable, Equatable, Hashable {
    case none = "None"
    case lined = "Lined"
    case grid = "Grid"
    case dotted = "Dotted"
    case ruled = "Ruled"
    case dashed = "Dashed"
    case crosshatch = "Cross-hatch"
    case columns = "Columns"
    case checkerboard = "Checkerboard"
    case diagonal = "Diagonal"
    case diamond = "Diamond"
    case honeycomb = "Honeycomb"
    case zigzag = "Zigzag"
    case waves = "Waves"
    case plusGrid = "Plus Grid"
    case circles = "Circles"
    case herringbone = "Herringbone"
    case brickwork = "Brickwork"
    case wideRuled = "Wide Ruled"
    case thinGrid = "Tight Grid"

    var id: String { rawValue }

    /// Background fill color for the style
    var backgroundColor: Color {
        switch self {
        case .none:         return .clear
        case .ruled, .wideRuled:
                            return Color(red: 0.99, green: 0.97, blue: 0.93)
        default:            return Color(.systemBackground)
        }
    }

    /// Overlay stroke / dot / fill color
    var overlayColor: Color {
        switch self {
        case .none:         return .clear
        case .lined:        return Color(.separator)
        case .grid:         return Color(.separator).opacity(0.6)
        case .dotted:       return Color(.separator).opacity(0.7)
        case .ruled:        return Color(.separator)
        case .dashed:       return Color(.separator).opacity(0.7)
        case .crosshatch:   return Color(.separator).opacity(0.4)
        case .columns:      return Color(.separator).opacity(0.5)
        case .checkerboard: return Color(.separator).opacity(0.08)
        case .diagonal:     return Color(.separator).opacity(0.45)
        case .diamond:      return Color(.separator).opacity(0.4)
        case .honeycomb:    return Color(.separator).opacity(0.35)
        case .zigzag:       return Color(.separator).opacity(0.5)
        case .waves:        return Color(.separator).opacity(0.45)
        case .plusGrid:     return Color(.separator).opacity(0.5)
        case .circles:      return Color(.separator).opacity(0.35)
        case .herringbone:  return Color(.separator).opacity(0.4)
        case .brickwork:    return Color(.separator).opacity(0.4)
        case .wideRuled:    return Color(.separator)
        case .thinGrid:     return Color(.separator).opacity(0.4)
        }
    }

    /// SF Symbol to represent in the picker grid
    var systemImage: String {
        switch self {
        case .none:          return "rectangle.slash"
        case .lined:         return "line.3.horizontal"
        case .grid:          return "grid"
        case .dotted:        return "circle.grid.3x3"
        case .ruled:         return "list.bullet"
        case .dashed:        return "line.3.horizontal"
        case .crosshatch:    return "xmark"
        case .columns:       return "rectangle.split.3x1"
        case .checkerboard:  return "checkerboard.rectangle"
        case .diagonal:      return "line.diagonal"
        case .diamond:       return "diamond"
        case .honeycomb:     return "hexagon"
        case .zigzag:        return "point.topleft.down.to.point.bottomright.curvepath"
        case .waves:         return "water.waves"
        case .plusGrid:      return "plus"
        case .circles:       return "circle"
        case .herringbone:   return "chevron.up"
        case .brickwork:     return "rectangle.split.3x3"
        case .wideRuled:     return "list.dash"
        case .thinGrid:      return "squareshape.split.3x3"
        }
    }
}

struct StickyNote: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var content: String
    var startDate: Date
    var endDate: Date
    var isDone: Bool
    var color: ColorCodable
    var category: NoteCategory
    var attachmentData: Data?
    var audioURLString: String?
    var videoURLString: String?
    var backgroundImageData: Data?
    var reminderDate: Date?
    var isTimeBounded: Bool
    var priority: Priority
    var reminderRepeat: ReminderRepeat
    var backgroundStyle: NoteBackgroundStyle

    var attachment: UIImage? {
        get { attachmentData.flatMap { UIImage(data: $0) } }
        set { attachmentData = newValue?.jpegData(compressionQuality: 0.8) }
    }
    var backgroundImage: UIImage? {
        get { backgroundImageData.flatMap { UIImage(data: $0) } }
        set { backgroundImageData = newValue?.jpegData(compressionQuality: 0.8) }
    }
    var audioURL: URL? {
        get { audioURLString.flatMap { URL(string: $0) } }
        set { audioURLString = newValue?.absoluteString }
    }
    var videoURL: URL? {
        get { videoURLString.flatMap { URL(string: $0) } }
        set { videoURLString = newValue?.absoluteString }
    }
    var colorValue: Color {
        get { color.color }
        set { color = ColorCodable(color: newValue) }
    }

    init(id: UUID = UUID(), title: String, content: String, startDate: Date, endDate: Date, isDone: Bool, color: Color, category: NoteCategory, attachment: UIImage?, audioURL: URL?, videoURL: URL?, backgroundImage: UIImage?, reminderDate: Date?, isTimeBounded: Bool, priority: Priority, reminderRepeat: ReminderRepeat = .never, backgroundStyle: NoteBackgroundStyle = .none) {
        self.id = id
        self.title = title
        self.content = content
        self.startDate = startDate
        self.endDate = endDate
        self.isDone = isDone
        self.color = ColorCodable(color: color)
        self.category = category
        self.attachmentData = attachment?.jpegData(compressionQuality: 0.8)
        self.audioURLString = audioURL?.absoluteString
        self.videoURLString = videoURL?.absoluteString
        self.backgroundImageData = backgroundImage?.jpegData(compressionQuality: 0.8)
        self.reminderDate = reminderDate
        self.isTimeBounded = isTimeBounded
        self.priority = priority
        self.reminderRepeat = reminderRepeat
        self.backgroundStyle = backgroundStyle
    }

    enum CodingKeys: String, CodingKey {
        case id, title, content, startDate, endDate, isDone, color, category, attachmentData, audioURLString, videoURLString, backgroundImageData, reminderDate, isTimeBounded, priority, reminderRepeat, backgroundStyle
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        isDone = try container.decode(Bool.self, forKey: .isDone)
        color = try container.decode(ColorCodable.self, forKey: .color)
        category = try container.decode(NoteCategory.self, forKey: .category)
        attachmentData = try container.decodeIfPresent(Data.self, forKey: .attachmentData)
        audioURLString = try container.decodeIfPresent(String.self, forKey: .audioURLString)
        videoURLString = try container.decodeIfPresent(String.self, forKey: .videoURLString)
        backgroundImageData = try container.decodeIfPresent(Data.self, forKey: .backgroundImageData)
        reminderDate = try container.decodeIfPresent(Date.self, forKey: .reminderDate)
        isTimeBounded = try container.decodeIfPresent(Bool.self, forKey: .isTimeBounded) ?? false
        priority = try container.decodeIfPresent(Priority.self, forKey: .priority) ?? .medium
        reminderRepeat = try container.decodeIfPresent(ReminderRepeat.self, forKey: .reminderRepeat) ?? .never
        backgroundStyle = try container.decodeIfPresent(NoteBackgroundStyle.self, forKey: .backgroundStyle) ?? .none
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(isDone, forKey: .isDone)
        try container.encode(color, forKey: .color)
        try container.encode(category, forKey: .category)
        try container.encodeIfPresent(attachmentData, forKey: .attachmentData)
        try container.encodeIfPresent(audioURLString, forKey: .audioURLString)
        try container.encodeIfPresent(videoURLString, forKey: .videoURLString)
        try container.encodeIfPresent(backgroundImageData, forKey: .backgroundImageData)
        try container.encodeIfPresent(reminderDate, forKey: .reminderDate)
        try container.encode(isTimeBounded, forKey: .isTimeBounded)
        try container.encode(priority, forKey: .priority)
        try container.encode(reminderRepeat, forKey: .reminderRepeat)
        try container.encode(backgroundStyle, forKey: .backgroundStyle)
    }
}

struct ColorCodable: Codable, Equatable, Hashable {
    let hex: String
    var color: Color { Color(hex: hex) }
    init(color: Color) { self.hex = color.toHex() ?? "#FFFF00" }
    init(hex: String) { self.hex = hex }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    func toHex() -> String? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%06x", rgb)
    }

    var isWhite: Bool {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return false }
        return abs(r - 1.0) < 0.01 && abs(g - 1.0) < 0.01 && abs(b - 1.0) < 0.01 && a > 0.95
    }
}
