//
//  File.swift
//  Stickies
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

class NotesViewModel: ObservableObject {
    @Published var notes: [StickyNote] = []
    @Published var searchQuery: String = ""
    @Published var sortOption: SortOption = .dateCreated

    enum SortOption {
        case dateCreated, title, category
    }

    var activeNotes: [StickyNote] {
        notes.filter { !$0.isDone }
    }

    var completedNotes: [StickyNote] {
        notes.filter { $0.isDone }
    }

    func addNote(title: String, content: String, startDate: Date, endDate: Date, color: Color, category: NoteCategory, attachment: UIImage?, audioURL: URL?, videoURL: URL?, reminderDate: Date?) -> StickyNote {
        let newNote = StickyNote(
            title: title,
            content: content,
            startDate: startDate,
            endDate: endDate,
            isDone: false,
            color: color,
            category: category,
            attachment: attachment,
            audioURL: audioURL,
            videoURL: videoURL,
            reminderDate: reminderDate
        )

        notes.append(newNote)
        return newNote
    }

    func updateNote(id: UUID, title: String, content: String, startDate: Date, endDate: Date, color: Color, category: NoteCategory, attachment: UIImage?, audioURL: URL?, videoURL: URL?, reminderDate: Date?) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].title = title
            notes[index].content = content
            notes[index].startDate = startDate
            notes[index].endDate = endDate
            notes[index].color = color
            notes[index].category = category
            notes[index].attachment = attachment
            notes[index].audioURL = audioURL
            notes[index].videoURL = videoURL
            notes[index].reminderDate = reminderDate
        }
    }

    func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
    }

    func markAsDone(id: UUID) {
        if let index = notes.firstIndex(where: { $0.id == id }) {
            notes[index].isDone.toggle()
            objectWillChange.send()
        }
    }
}
