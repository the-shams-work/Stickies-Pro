//
//  NotesViewModel.swift
//  Kipp
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
    @Published var selectedCategoryFilter: NoteCategory?
    @Published var showOnlyWithAttachments: Bool = false
    @Published var showOnlyWithReminders: Bool = false
    @Published var dateFilterOption: DateFilterOption = .all

    enum SortOption {
        case dateCreated, title, category, priority
    }
    
    enum DateFilterOption: String, CaseIterable {
        case all = "All"
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case overdue = "Overdue"
        
        var systemImage: String {
            switch self {
            case .all: return "calendar"
            case .today: return "calendar.badge.clock"
            case .thisWeek: return "calendar.badge.plus"
            case .thisMonth: return "calendar.badge.exclamationmark"
            case .overdue: return "exclamationmark.triangle"
            }
        }
    }

    private let notesFileName = "notes.json"
    private var notesFileURL: URL {
        let manager = FileManager.default
        let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return url.appendingPathComponent(notesFileName)
    }

    init() {
        loadNotes()
        removeExpiredNotes()
    }

    var filteredNotes: [StickyNote] {
        var notes = self.notes.filter { !$0.isDone && $0.startDate <= Date() }
        
        // Search filter
        if !searchQuery.isEmpty {
            notes = notes.filter {
                $0.title.localizedCaseInsensitiveContains(searchQuery) ||
                $0.content.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        // Category filter
        if let selectedCategory = selectedCategoryFilter {
            notes = notes.filter { $0.category == selectedCategory }
        }
        
        // Attachment filter
        if showOnlyWithAttachments {
            notes = notes.filter { $0.attachment != nil || $0.audioURL != nil || $0.videoURL != nil }
        }
        
        // Reminder filter
        if showOnlyWithReminders {
            notes = notes.filter { $0.reminderDate != nil }
        }
        
        // Date filter
        let calendar = Calendar.current
        let now = Date()
        
        switch dateFilterOption {
        case .today:
            notes = notes.filter { calendar.isDateInToday($0.startDate) }
        case .thisWeek:
            notes = notes.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .weekOfYear) }
        case .thisMonth:
            notes = notes.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .month) }
        case .overdue:
            notes = notes.filter { $0.endDate < now }
        case .all:
            break
        }
        
        // Sort
        switch sortOption {
        case .dateCreated:
            notes.sort { $0.startDate > $1.startDate }
        case .title:
            notes.sort { $0.title.lowercased() < $1.title.lowercased() }
        case .category:
            notes.sort { $0.category.rawValue < $1.category.rawValue }
        case .priority:
            notes.sort { $0.priority.sortOrder > $1.priority.sortOrder }
        }
        
        return notes
    }
    
    var archivedNotes: [StickyNote] {
        var notes = self.notes.filter { $0.isDone }
        
        // Search filter
        if !searchQuery.isEmpty {
            notes = notes.filter {
                $0.title.localizedCaseInsensitiveContains(searchQuery) ||
                $0.content.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        // Category filter
        if let selectedCategory = selectedCategoryFilter {
            notes = notes.filter { $0.category == selectedCategory }
        }
        
        // Attachment filter
        if showOnlyWithAttachments {
            notes = notes.filter { $0.attachment != nil || $0.audioURL != nil || $0.videoURL != nil }
        }
        
        // Reminder filter
        if showOnlyWithReminders {
            notes = notes.filter { $0.reminderDate != nil }
        }
        
        // Date filter
        let calendar = Calendar.current
        let now = Date()
        
        switch dateFilterOption {
        case .today:
            notes = notes.filter { calendar.isDateInToday($0.startDate) }
        case .thisWeek:
            notes = notes.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .weekOfYear) }
        case .thisMonth:
            notes = notes.filter { calendar.isDate($0.startDate, equalTo: now, toGranularity: .month) }
        case .overdue:
            notes = notes.filter { $0.endDate < now }
        case .all:
            break
        }
        
        // Sort
        switch sortOption {
        case .dateCreated:
            notes.sort { $0.startDate > $1.startDate }
        case .title:
            notes.sort { $0.title.lowercased() < $1.title.lowercased() }
        case .category:
            notes.sort { $0.category.rawValue < $1.category.rawValue }
        case .priority:
            notes.sort { $0.priority.sortOrder > $1.priority.sortOrder }
        }
        
        return notes
    }
    

    func saveNotes() {
        do {
            let data = try JSONEncoder().encode(notes)
            try data.write(to: notesFileURL)
            print("Notes saved to disk.")
        } catch {
            print("Failed to save notes: \(error)")
        }
    }

    func loadNotes() {
        do {
            let data = try Data(contentsOf: notesFileURL)
            notes = try JSONDecoder().decode([StickyNote].self, from: data)
            print("Notes loaded from disk.")
            removeExpiredNotes()
        } catch {
            print("No saved notes found or failed to load: \(error)")
        }
    }

    func addNote(title: String, content: String, startDate: Date, endDate: Date, color: Color, category: NoteCategory, attachment: UIImage?, audioURL: URL?, videoURL: URL?, reminderDate: Date?, isTimeBounded: Bool, priority: Priority, reminderRepeat: ReminderRepeat) -> StickyNote {
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
            reminderDate: reminderDate,
            isTimeBounded: isTimeBounded,
            priority: priority,
            reminderRepeat: reminderRepeat
        )
        notes.append(newNote)
        return newNote
    }

    func updateNote(id: UUID, title: String, content: String, startDate: Date, endDate: Date, color: Color, category: NoteCategory, attachment: UIImage?, audioURL: URL?, videoURL: URL?, reminderDate: Date?, isTimeBounded: Bool, priority: Priority, reminderRepeat: ReminderRepeat) {
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
            notes[index].isTimeBounded = isTimeBounded
            notes[index].priority = priority
            notes[index].reminderRepeat = reminderRepeat
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

    func removeExpiredNotes() {
        let today = Calendar.current.startOfDay(for: Date())
        notes.removeAll { $0.isTimeBounded && $0.endDate < today }
        saveNotes()
    }
}
