//
//  StickyNote.swift
//  Stickies Pro
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

enum NoteCategory: String, CaseIterable, Identifiable, Codable {
    case todo = "To Do 📅"
    case journal = "Journals 📝"
    case ideas = "Ideas 💡"
    case study = "Study Notes 📚"
    case finance = "Finance 💰"
    case work = "Work Notes 📁"
    case goals = "Goals 🎯"
    case important = "Important 📌"
    case projects = "Projects 📊"
    case music = "Music & Lyrics 🎶"
    case books = "Book Notes 📖"
    case movies = "Movie Reviews 🎬"
    case art = "Art & Design 🎨"
    case writing = "Writing & Blog ✍️"
    case diet = "Diet & Fitness 🥗"
    case mental = "Mental Wellness 🧘"
    case health = "Health Records 🏥"
    case travel = "Travel Plans 🛫"
    case memories = "Memories 📸"
    case urgent = "Urgent ⚠️"
    case home = "Home & Family 🏠"
    case shopping = "Shopping List 🛍️"

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
    var attachmentData: Data? // UIImage as Data
    var audioURLString: String? // URL as String
    var videoURLString: String? // URL as String
    var reminderDate: Date?

    // Computed properties for UI use
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

    init(id: UUID = UUID(), title: String, content: String, startDate: Date, endDate: Date, isDone: Bool, color: Color, category: NoteCategory, attachment: UIImage?, audioURL: URL?, videoURL: URL?, reminderDate: Date?) {
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
    }

    enum CodingKeys: String, CodingKey {
        case id, title, content, startDate, endDate, isDone, color, category, attachmentData, audioURLString, videoURLString, reminderDate
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
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
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
