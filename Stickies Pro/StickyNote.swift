//
//  StickyNote.swift
//  Stickies
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

enum NoteCategory: String, CaseIterable, Identifiable {
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

struct StickyNote: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var startDate: Date
    var endDate: Date
    var isDone: Bool
    var color: Color
    var category: NoteCategory
    var attachment: UIImage?
    var audioURL: URL?
    var videoURL: URL?
    var reminderDate: Date?
}
