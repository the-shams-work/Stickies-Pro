//
//  StickyNote.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

enum NoteCategory: String, CaseIterable, Identifiable, Codable {
    case todo = "To Do"
    case journal = "Journals"
    case ideas = "Ideas"
    case study = "Study Notes"
    case finance = "Finance"
    case work = "Work Notes"
    case goals = "Goals"
    case important = "Important"
    case projects = "Projects"
    case music = "Music & Lyrics"
    case books = "Book Notes"
    case movies = "Movie Reviews"
    case art = "Art & Design"
    case writing = "Writing & Blog"
    case diet = "Diet & Fitness"
    case mental = "Mental Wellness"
    case health = "Health Records"
    case travel = "Travel Plans"
    case memories = "Memories"
    case urgent = "Urgent"
    case home = "Home & Family"
    case shopping = "Shopping List"

    var id: String { self.rawValue }
    
    var systemImage: String {
        switch self {
        case .todo:
            return "checklist"
        case .journal:
            return "book"
        case .ideas:
            return "lightbulb"
        case .study:
            return "graduationcap"
        case .finance:
            return "dollarsign.circle"
        case .work:
            return "briefcase"
        case .goals:
            return "target"
        case .important:
            return "exclamationmark.triangle"
        case .projects:
            return "chart.bar"
        case .music:
            return "music.note"
        case .books:
            return "text.book.closed"
        case .movies:
            return "film"
        case .art:
            return "paintbrush"
        case .writing:
            return "pencil"
        case .diet:
            return "leaf"
        case .mental:
            return "brain.head.profile"
        case .health:
            return "cross.case"
        case .travel:
            return "airplane"
        case .memories:
            return "photo"
        case .urgent:
            return "exclamationmark.octagon"
        case .home:
            return "house"
        case .shopping:
            return "cart"
        }
    }
}

enum Priority: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
    
    var id: String { self.rawValue }
    
    var sortOrder: Int {
        switch self {
        case .urgent: return 3
        case .high: return 2
        case .medium: return 1
        case .low: return 0
        }
    }
    
    var systemImage: String {
        switch self {
        case .low:
            return "arrow.down.circle"
        case .medium:
            return "minus.circle"
        case .high:
            return "arrow.up.circle"
        case .urgent:
            return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .low:
            return .green
        case .medium:
            return .blue
        case .high:
            return .orange
        case .urgent:
            return .red
        }
    }
}

enum ReminderRepeat: String, CaseIterable, Codable, Identifiable {
    case never = "Never"
    case daily = "Every Day"
    case weekly = "Every Week"
    case biweekly = "Every 2 Weeks"
    case monthly = "Every Month"
    case yearly = "Every Year"
    // case custom = "Custom" // For future advanced support

    var id: String { self.rawValue }
}

struct StickyNote: Identifiable, Codable {
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
    var reminderDate: Date?
    var isTimeBounded: Bool
    var priority: Priority
    var reminderRepeat: ReminderRepeat

    var attachment: UIImage? {
        get { attachmentData.flatMap { UIImage(data: $0) } }
        set { attachmentData = newValue?.jpegData(compressionQuality: 0.8) }
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

    init(id: UUID = UUID(), title: String, content: String, startDate: Date, endDate: Date, isDone: Bool, color: Color, category: NoteCategory, attachment: UIImage?, audioURL: URL?, videoURL: URL?, reminderDate: Date?, isTimeBounded: Bool, priority: Priority, reminderRepeat: ReminderRepeat = .never) {
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
        self.reminderDate = reminderDate
        self.isTimeBounded = isTimeBounded
        self.priority = priority
        self.reminderRepeat = reminderRepeat
    }

    enum CodingKeys: String, CodingKey {
        case id, title, content, startDate, endDate, isDone, color, category, attachmentData, audioURLString, videoURLString, reminderDate, isTimeBounded, priority, reminderRepeat
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
        reminderDate = try container.decodeIfPresent(Date.self, forKey: .reminderDate)
        isTimeBounded = try container.decodeIfPresent(Bool.self, forKey: .isTimeBounded) ?? false
        priority = try container.decodeIfPresent(Priority.self, forKey: .priority) ?? .medium
        reminderRepeat = try container.decodeIfPresent(ReminderRepeat.self, forKey: .reminderRepeat) ?? .never
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
        try container.encodeIfPresent(reminderDate, forKey: .reminderDate)
        try container.encode(isTimeBounded, forKey: .isTimeBounded)
        try container.encode(priority, forKey: .priority)
        try container.encode(reminderRepeat, forKey: .reminderRepeat)
    }
}

struct ColorCodable: Codable {
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
}
