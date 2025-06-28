//
//  File.swift
//  Stickies Pro
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

class NotesViewModel: ObservableObject {
    @Published var notes: [StickyNote] = [] {
        didSet {
            saveNotes()
        }
    }
    @Published var searchQuery: String = ""
    @Published var sortOption: SortOption = .dateCreated

    enum SortOption {
        case dateCreated, title, category
    }

    private let notesFileName = "notes.json"
    private var notesFileURL: URL {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent(notesFileName)
    }

    init() {
        loadNotes()
    }

    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: notesFileURL)
            print("✅ Notes saved to disk.")
        } catch {
            print("❌ Failed to save notes: \(error)")
        }
    }

    func loadNotes() {
        do {
            let data = try Data(contentsOf: notesFileURL)
            notes = try JSONDecoder().decode([StickyNote].self, from: data)
            print("✅ Notes loaded from disk.")
        } catch {
            print("⚠️ No saved notes found or failed to load: \(error)")
        }
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
            notes[index].colorValue = color
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
