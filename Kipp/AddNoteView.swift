//
//  AddNoteView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import AVKit

struct AddNoteView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Binding var showAddNote: Bool
    
    var editingNote: StickyNote?
    
    @State private var title: String
    @State private var content: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedColor: Color
    @State private var selectedCategory: NoteCategory?
    @State private var selectedImage: UIImage?
    @State private var selectedAudioURL: URL?
    @State private var selectedVideoURL: URL?
    @State private var reminderDate: Date?
    @State private var isTimeBounded: Bool
    @State private var wantsReminder: Bool
    @State private var selectedPriority: Priority
    @State private var selectedRepeat: ReminderRepeat
    
    // Validation state variables
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var showFutureNoteAlert = false

    let today = Date()

    init(viewModel: NotesViewModel, showAddNote: Binding<Bool>, editingNote: StickyNote? = nil) {
        self.viewModel = viewModel
        self._showAddNote = showAddNote
        self.editingNote = editingNote
        
        _title = State(initialValue: editingNote?.title ?? "")
        _content = State(initialValue: editingNote?.content ?? "")
        _startDate = State(initialValue: editingNote?.startDate ?? Date())
        _endDate = State(initialValue: editingNote?.endDate ?? Date())
        _selectedColor = State(initialValue: editingNote?.colorValue ?? Color.yellow)
        _selectedCategory = State(initialValue: editingNote?.category)
        _selectedImage = State(initialValue: editingNote?.attachment)
        _selectedAudioURL = State(initialValue: editingNote?.audioURL)
        _selectedVideoURL = State(initialValue: editingNote?.videoURL)
        _reminderDate = State(initialValue: editingNote?.reminderDate)
        _isTimeBounded = State(initialValue: {
            guard let editingNote = editingNote else { return false }
            let today = Date()
            let calendar = Calendar.current
            // Only set as time-bounded if the note actually has different start/end dates
            return !calendar.isDate(editingNote.startDate, inSameDayAs: editingNote.endDate)
        }())
        _wantsReminder = State(initialValue: editingNote?.reminderDate != nil)
        _selectedPriority = State(initialValue: editingNote?.priority ?? .none)
        _selectedRepeat = State(initialValue: editingNote?.reminderRepeat ?? .never)
    }

    // MARK: - Validation Function
    private func validateNote() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter a title for your note."
            showValidationAlert = true
            return false
        }
        
        if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter content for your note."
            showValidationAlert = true
            return false
        }
        
        if selectedCategory == nil {
            validationMessage = "Please select a category for your note."
            showValidationAlert = true
            return false
        }
        
        return true
    }
    
    private func saveNote() {
        guard validateNote() else { return }
        
        let calendar = Calendar.current
        let today = Date()
        
        // For non-time-bounded notes, set both start and end date to today
        // For time-bounded notes, use the selected dates
        let useStartDate = isTimeBounded ? startDate : today
        let useEndDate = isTimeBounded ? endDate : today
        let useReminderDate = wantsReminder ? reminderDate : nil
        let isFutureStart = !calendar.isDateInToday(useStartDate) && useStartDate > today

        if let editingNote {
            viewModel.updateNote(
                id: editingNote.id,
                title: title,
                content: content,
                startDate: useStartDate,
                endDate: useEndDate,
                color: selectedColor,
                category: selectedCategory!,
                attachment: selectedImage,
                audioURL: selectedAudioURL,
                videoURL: selectedVideoURL,
                reminderDate: useReminderDate,
                isTimeBounded: isTimeBounded,
                priority: selectedPriority,
                reminderRepeat: selectedRepeat
            )

            if let reminderDate = useReminderDate {
                NotificationManager.shared.removeNotification(identifier: editingNote.id.uuidString)
                NotificationManager.shared.scheduleNotification(
                    title: "Reminder: \(title)",
                    body: content,
                    date: reminderDate,
                    identifier: editingNote.id.uuidString
                )
            }
        } else {
            let newNote = viewModel.addNote(
                title: title,
                content: content,
                startDate: useStartDate,
                endDate: useEndDate,
                color: selectedColor,
                category: selectedCategory!,
                attachment: selectedImage,
                audioURL: selectedAudioURL,
                videoURL: selectedVideoURL,
                reminderDate: useReminderDate,
                isTimeBounded: isTimeBounded,
                priority: selectedPriority,
                reminderRepeat: selectedRepeat
            )

            if let reminderDate = useReminderDate, reminderDate > Date() {
                NotificationManager.shared.scheduleNotification(
                    title: "Reminder: \(title)",
                    body: content,
                    date: reminderDate,
                    identifier: newNote.id.uuidString
                )
            }
        }
        if isFutureStart {
            showFutureNoteAlert = true
        } else {
            showAddNote = false
        }
    }

    var body: some View {
        Form {
            Section(header: Text("Note Details")) {
                TextField("Title", text: $title)
                TextField("Content",text: $content, axis: .vertical)
                    .lineLimit(5, reservesSpace: true)
            }

            Section(header: Text("Date & Time"), footer: isTimeBounded ? AnyView(
                Text("When 'Date Range' is enabled, you can set a start and end date for your note. The note will be active and visible only during this period.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            ) : AnyView(EmptyView())) {
                Toggle("Date Range", isOn: Binding(
                    get: { isTimeBounded },
                    set: { newValue in
                        isTimeBounded = newValue
                        if !newValue {
                            // When disabling, reset dates to today
                            startDate = today
                            endDate = today
                        }
                    }
                ))
                if isTimeBounded {
                    DatePicker("Start", selection: $startDate, in: today..., displayedComponents: .date)
                    DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: .date)
                }
                Toggle("Reminder", isOn: $wantsReminder)
                if wantsReminder {
                    DatePicker("Date & Time", selection: Binding(
                        get: { reminderDate ?? today },
                        set: { reminderDate = $0 }
                    ), in: today..., displayedComponents: [.date, .hourAndMinute])
                    Picker("Repeat", selection: $selectedRepeat) {
                        Text("Never").tag(ReminderRepeat.never)
                        Divider()
                        ForEach(ReminderRepeat.allCases.filter { $0 != .never }) { repeatOption in
                            Text(repeatOption.rawValue).tag(repeatOption)
                        }
                    }
                }
            }

            Section(header: Text("Customization")) {
                ColorPicker("Note Color", selection: $selectedColor)

                Picker("Priority", selection: $selectedPriority) {
                    Text("None").tag(Priority.none)
                    Divider()
                    ForEach(Priority.allCases.filter { $0 != .none }) { priority in
                        PriorityRowView(priority: priority)
                            .tag(priority)
                    }
                }
                .tint(.purple)
                
                Picker("Category", selection: $selectedCategory) {
                    Text("Select Category").tag(nil as NoteCategory?)
                    Divider()
                    ForEach(NoteCategory.allCases) { category in
                        CategoryRowView(category: category)
                            .tag(category as NoteCategory?)
                    }
                }
                .tint(.purple)
            }

            Section(header: Text("Attachments")) {
                ImagePickerButton(selectedImage: $selectedImage)
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(8)
                }

                AudioPickerButton(selectedAudioURL: $selectedAudioURL)
                if let audioURL = selectedAudioURL {
                    Text("Audio: \(audioURL.lastPathComponent)")
                }

                VideoPickerButton(selectedVideoURL: $selectedVideoURL)
                if let videoURL = selectedVideoURL {
                    Text("Video: \(videoURL.lastPathComponent)")
                }
            }
        }
        .tint(.purple)
        .navigationBarTitle(editingNote == nil ? "New Note" : "Edit Sticky Note", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") { 
                    showAddNote = false 
                }
                .foregroundColor(.purple)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    saveNote()
                }
                .foregroundColor(.purple)
            }
        }
        .alert("Validation Error", isPresented: $showValidationAlert) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
        .alert("Note Scheduled", isPresented: $showFutureNoteAlert) {
            Button("OK") { showAddNote = false }
        } message: {
            Text("Your note will be activated and shown as per your selected date.")
        }
    }
}

struct CategoryRowView: View {
    let category: NoteCategory

    var body: some View {
        Label(category.rawValue, systemImage: category.systemImage)
    }
}

struct PriorityRowView: View {
    let priority: Priority

    var body: some View {
        Label(priority.rawValue, systemImage: priority.systemImage)
    }
}

