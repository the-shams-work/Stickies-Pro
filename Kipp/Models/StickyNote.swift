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
        case .todo: return String(localized: "category.subtitle.todo")
        case .journal: return String(localized: "category.subtitle.journal")
        case .ideas: return String(localized: "category.subtitle.ideas")
        case .study: return String(localized: "category.subtitle.study")
        case .finance: return String(localized: "category.subtitle.finance")
        case .work: return String(localized: "category.subtitle.work")
        case .goals: return String(localized: "category.subtitle.goals")
        case .important: return String(localized: "category.subtitle.important")
        case .projects: return String(localized: "category.subtitle.projects")
        case .music: return String(localized: "category.subtitle.music")
        case .books: return String(localized: "category.subtitle.books")
        case .movies: return String(localized: "category.subtitle.movies")
        case .art: return String(localized: "category.subtitle.art")
        case .writing: return String(localized: "category.subtitle.writing")
        case .diet: return String(localized: "category.subtitle.diet")
        case .mental: return String(localized: "category.subtitle.mental")
        case .health: return String(localized: "category.subtitle.health")
        case .travel: return String(localized: "category.subtitle.travel")
        case .memories: return String(localized: "category.subtitle.memories")
        case .urgent: return String(localized: "category.subtitle.urgent")
        case .home: return String(localized: "category.subtitle.home")
        case .shopping: return String(localized: "category.subtitle.shopping")
        case .custom: return String(localized: "category.subtitle.custom")
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
        case .none: return String(localized: "priority.subtitle.none")
        case .low: return String(localized: "priority.subtitle.low")
        case .medium: return String(localized: "priority.subtitle.medium")
        case .high: return String(localized: "priority.subtitle.high")
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
    var fileURLString: String?
    var backgroundImageData: Data?
    var reminderDate: Date?
    var isTimeBounded: Bool
    var priority: Priority
    var reminderRepeat: ReminderRepeat
    var backgroundStyle: NoteBackgroundStyle
    var isPinned: Bool
    var locationName: String?
    var locationLatitude: Double?
    var locationLongitude: Double?

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
    var fileURL: URL? {
        get { fileURLString.flatMap { URL(string: $0) } }
        set { fileURLString = newValue?.absoluteString }
    }
    var colorValue: Color {
        get { color.color }
        set { color = ColorCodable(color: newValue) }
    }

    init(id: UUID = UUID(), title: String, content: String, startDate: Date, endDate: Date, isDone: Bool, color: Color, category: NoteCategory, attachment: UIImage?, audioURL: URL?, videoURL: URL?, fileURL: URL? = nil, backgroundImage: UIImage?, reminderDate: Date?, isTimeBounded: Bool, priority: Priority, reminderRepeat: ReminderRepeat = .never, backgroundStyle: NoteBackgroundStyle = .none, isPinned: Bool = false, locationName: String? = nil, locationLatitude: Double? = nil, locationLongitude: Double? = nil) {
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
        self.fileURLString = fileURL?.absoluteString
        self.backgroundImageData = backgroundImage?.jpegData(compressionQuality: 0.8)
        self.reminderDate = reminderDate
        self.isTimeBounded = isTimeBounded
        self.priority = priority
        self.reminderRepeat = reminderRepeat
        self.backgroundStyle = backgroundStyle
        self.isPinned = isPinned
        self.locationName = locationName
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
    }

    enum CodingKeys: String, CodingKey {
        case id, title, content, startDate, endDate, isDone, color, category, attachmentData, audioURLString, videoURLString, fileURLString, backgroundImageData, reminderDate, isTimeBounded, priority, reminderRepeat, backgroundStyle, isPinned, locationName, locationLatitude, locationLongitude
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
        fileURLString = try container.decodeIfPresent(String.self, forKey: .fileURLString)
        backgroundImageData = try container.decodeIfPresent(Data.self, forKey: .backgroundImageData)
        reminderDate = try container.decodeIfPresent(Date.self, forKey: .reminderDate)
        isTimeBounded = try container.decodeIfPresent(Bool.self, forKey: .isTimeBounded) ?? false
        priority = try container.decodeIfPresent(Priority.self, forKey: .priority) ?? .medium
        reminderRepeat = try container.decodeIfPresent(ReminderRepeat.self, forKey: .reminderRepeat) ?? .never
        backgroundStyle = try container.decodeIfPresent(NoteBackgroundStyle.self, forKey: .backgroundStyle) ?? .none
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        locationName = try container.decodeIfPresent(String.self, forKey: .locationName)
        locationLatitude = try container.decodeIfPresent(Double.self, forKey: .locationLatitude)
        locationLongitude = try container.decodeIfPresent(Double.self, forKey: .locationLongitude)
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
        try container.encodeIfPresent(fileURLString, forKey: .fileURLString)
        try container.encodeIfPresent(backgroundImageData, forKey: .backgroundImageData)
        try container.encodeIfPresent(reminderDate, forKey: .reminderDate)
        try container.encode(isTimeBounded, forKey: .isTimeBounded)
        try container.encode(priority, forKey: .priority)
        try container.encode(reminderRepeat, forKey: .reminderRepeat)
        try container.encode(backgroundStyle, forKey: .backgroundStyle)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encodeIfPresent(locationName, forKey: .locationName)
        try container.encodeIfPresent(locationLatitude, forKey: .locationLatitude)
        try container.encodeIfPresent(locationLongitude, forKey: .locationLongitude)
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
        // Try getRed first; fall back to cgColor components for system/P3 colors
        if !uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            guard let components = uiColor.cgColor.components else { return nil }
            if components.count >= 4 {
                r = components[0]; g = components[1]; b = components[2]; a = components[3]
            } else if components.count >= 2 {
                r = components[0]; g = components[0]; b = components[0]; a = components[1]
            } else {
                return nil
            }
        }
        // Clamp to 0...1
        r = min(max(r, 0), 1)
        g = min(max(g, 0), 1)
        b = min(max(b, 0), 1)
        a = min(max(a, 0), 1)
        // Use 8-char ARGB hex to preserve alpha (needed for Color.clear / "None")
        let argb: Int = (Int)(a*255)<<24 | (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format: "#%08x", argb)
    }

    /// Whether this color should be treated as "light" for text-contrast purposes.
    /// Transparent ("None") and white both return true so dark text is used.
    var isLightColor: Bool {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if !uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) {
            if let c = uiColor.cgColor.components, c.count >= 4 {
                r = c[0]; g = c[1]; b = c[2]; a = c[3]
            } else {
                return false
            }
        }
        // Transparent / clear → treat as light (system background)
        if a < 0.05 { return true }
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.6
    }
}
