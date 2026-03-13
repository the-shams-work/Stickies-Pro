//
//  AddNoteView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import AVKit

struct AddNoteView: View {
    @EnvironmentObject var themeManager: ThemeManager
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
    @State private var selectedBackgroundImage: UIImage?
    @State private var reminderDate: Date?
    @State private var isTimeBounded: Bool
    @State private var wantsReminder: Bool
    @State private var selectedPriority: Priority
    @State private var selectedRepeat: ReminderRepeat
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var showFutureNoteAlert = false
    @State private var selectedFileURL: URL?
    @State private var selectedBackgroundStyle: NoteBackgroundStyle

    let today = Date()

    init(viewModel: NotesViewModel, showAddNote: Binding<Bool>, editingNote: StickyNote? = nil) {
        self.viewModel = viewModel
        self._showAddNote = showAddNote
        self.editingNote = editingNote
        
        _title = State(initialValue: editingNote?.title ?? "")
        _content = State(initialValue: editingNote?.content ?? "")
        _startDate = State(initialValue: editingNote?.startDate ?? Date())
        _endDate = State(initialValue: editingNote?.endDate ?? Date())
        _selectedColor = State(initialValue: editingNote?.colorValue ?? Color.clear)
        _selectedCategory = State(initialValue: editingNote?.category)
        _selectedImage = State(initialValue: editingNote?.attachment)
        _selectedAudioURL = State(initialValue: editingNote?.audioURL)
        _selectedVideoURL = State(initialValue: editingNote?.videoURL)
        _selectedBackgroundImage = State(initialValue: editingNote?.backgroundImage)
        _reminderDate = State(initialValue: editingNote?.reminderDate)
        _isTimeBounded = State(initialValue: {
            guard let editingNote = editingNote else { return false }
            let today = Date()
            let calendar = Calendar.current
            return !calendar.isDate(editingNote.startDate, inSameDayAs: editingNote.endDate)
        }())
        _wantsReminder = State(initialValue: editingNote?.reminderDate != nil)
        _selectedPriority = State(initialValue: editingNote?.priority ?? .none)
        _selectedRepeat = State(initialValue: editingNote?.reminderRepeat ?? .never)
        _selectedFileURL = State(initialValue: editingNote?.fileURL)
        _selectedBackgroundStyle = State(initialValue: editingNote?.backgroundStyle ?? .none)
    }

    // MARK: - Validation Function
    private func validateNote() -> Bool {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "addnote.validation.title"
            showValidationAlert = true
            return false
        }
        
        if content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "addnote.validation.content"
            showValidationAlert = true
            return false
        }
        
        if selectedCategory == nil {
            validationMessage = "addnote.validation.category"
            showValidationAlert = true
            return false
        }
        
        return true
    }
    
    private func saveNote() {
        guard validateNote() else { return }
        
        let calendar = Calendar.current
        let today = Date()
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
                fileURL: selectedFileURL,
                backgroundImage: selectedBackgroundImage,
                reminderDate: useReminderDate,
                isTimeBounded: isTimeBounded,
                priority: selectedPriority,
                reminderRepeat: selectedRepeat,
                backgroundStyle: selectedBackgroundStyle
            )

            if let reminderDate = useReminderDate {
                NotificationManager.shared.removeNotification(identifier: editingNote.id.uuidString)
                NotificationManager.shared.scheduleNotification(
                    title: "\(String(localized: "stickynote.reminder.set")): \(title)",
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
                fileURL: selectedFileURL,
                backgroundImage: selectedBackgroundImage,
                reminderDate: useReminderDate,
                isTimeBounded: isTimeBounded,
                priority: selectedPriority,
                reminderRepeat: selectedRepeat,
                backgroundStyle: selectedBackgroundStyle
            )

            if let reminderDate = useReminderDate, reminderDate > Date() {
                NotificationManager.shared.scheduleNotification(
                    title: "\(String(localized: "stickynote.reminder.set")): \(title)",
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
    
    @ViewBuilder
    private var noteDetailsSection: some View {
        Section {
            TextField("addnote.title.field", text: $title)
                .font(.body)
            TextField("addnote.content.field", text: $content, axis: .vertical)
                .lineLimit(5, reservesSpace: true)
        } header: {
            Text("addnote.details")
        }
    }

    @ViewBuilder
    private var dateTimeSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { isTimeBounded },
                set: { newValue in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        isTimeBounded = newValue
                        if !newValue {
                            startDate = today
                            endDate = today
                        }
                    }
                }
            )) {
                HStack(spacing: 14) {
                    HIGIcon(systemName: "calendar", color: .blue)
                    Text("home.filters.date")
                }
            }

            if isTimeBounded {
                DatePicker("common.start", selection: $startDate, in: today..., displayedComponents: .date)
                DatePicker("common.end", selection: $endDate, in: startDate..., displayedComponents: .date)
            }

            Toggle(isOn: Binding(
                get: { wantsReminder },
                set: { newValue in
                    withAnimation(.easeInOut(duration: 0.25)) {
                        wantsReminder = newValue
                    }
                }
            )) {
                HStack(spacing: 14) {
                    HIGIcon(systemName: "bell.badge.fill", color: .purple)
                    Text("stickynote.reminder")
                }
            }

            if wantsReminder {
                DatePicker("addnote.datetime", selection: Binding(
                    get: { reminderDate ?? today },
                    set: { reminderDate = $0 }
                ), in: today..., displayedComponents: [.date, .hourAndMinute])
                Picker("addnote.reminders.repeat", selection: $selectedRepeat) {
                    Text("addnote.reminders.never").tag(ReminderRepeat.never)
                    Divider()
                    ForEach(ReminderRepeat.allCases.filter { $0 != .never }) { repeatOption in
                        Text(LocalizedStringKey(repeatOption.rawValue)).tag(repeatOption)
                    }
                }
            }
        } footer: {
            if isTimeBounded {
                Text("addnote.datetime.info")
            }
        }
    }

    @ViewBuilder
    private var customizationSection: some View {
        Section {
            // Note Color
            NavigationLink {
                NoteColorPickerView(selectedColor: $selectedColor)
            } label: {
                HStack(spacing: 14) {
                    HIGIcon(systemName: "paintpalette.fill", color: .orange)
                    Text("addnote.color")
                        .foregroundColor(.primary)
                    Spacer()
                    if UIColor(selectedColor).cgColor.alpha < 0.05 {
                        // "None" — show slash indicator
                        Circle()
                            .stroke(Color(.separator), lineWidth: 1)
                            .frame(width: 22, height: 22)
                            .overlay(
                                Rectangle()
                                    .fill(Color(.separator))
                                    .frame(width: 1, height: 16)
                                    .rotationEffect(.degrees(45))
                            )
                    } else {
                        Circle()
                            .fill(selectedColor)
                            .frame(width: 22, height: 22)
                    }
                }
            }

            // Background Image
            NavigationLink {
                AddPhotoView(selectedImage: $selectedBackgroundImage)
                    .navigationTitle(String(localized: "addnote.background.image.title"))
            } label: {
                HStack(spacing: 14) {
                    HIGIcon(systemName: "photo.on.rectangle.angled", color: .blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("addnote.background")
                            .foregroundColor(.primary)
                        if selectedBackgroundImage != nil {
                            Text("addnote.selected.image")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    if selectedBackgroundImage != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }
                }
            }

            // Background Style
            NavigationLink {
                BackgroundStylePickerView(selectedStyle: $selectedBackgroundStyle)
            } label: {
                HStack(spacing: 14) {
                    HIGIcon(systemName: "rectangle.3.group.fill", color: .purple)
                    Text("addnote.background.style")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(LocalizedStringKey(selectedBackgroundStyle.rawValue))
                        .foregroundColor(.secondary)
                }
            }

            // Priority
            NavigationLink {
                PriorityPickerView(selectedPriority: $selectedPriority)
            } label: {
                HStack(spacing: 14) {
                    HIGIcon(systemName: "flag.fill", color: Color(.systemPink))
                    Text("addnote.priority")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(LocalizedStringKey(selectedPriority.rawValue))
                        .foregroundColor(.secondary)
                }
            }

            // Category
            NavigationLink {
                CategoryPickerView(selectedCategory: $selectedCategory)
            } label: {
                HStack(spacing: 14) {
                    HIGIcon(systemName: "tag.fill", color: .green)
                    Text("addnote.category")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(selectedCategory?.rawValue ?? String(localized: "addnote.category.select"))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        } header: {
            Text("addnote.customization")
        }
    }

    @ViewBuilder
    private var attachmentsSection: some View {
        Section {
            // Photo
            NavigationLink {
                AddPhotoView(selectedImage: $selectedImage)
            } label: {
                HStack(spacing: 14) {
                    HIGIcon(systemName: "camera.fill", color: .blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("addnote.attachments.photo")
                            .foregroundColor(.primary)
                        if selectedImage != nil {
                            Text("addnote.selected.photo")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                    if selectedImage != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }
                }
            }

            // Audio
            NavigationLink {
                AddAudioView(selectedAudioURL: $selectedAudioURL)
            } label: {
                HStack(spacing: 14) {
                    HIGIcon(systemName: "mic.fill", color: .orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("addnote.attachments.audio.label")
                            .foregroundColor(.primary)
                        if let audioURL = selectedAudioURL {
                            Text(audioURL.lastPathComponent)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                    if selectedAudioURL != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }
                }
            }

            // Video
            NavigationLink {
                AddVideoView(selectedVideoURL: $selectedVideoURL)
            } label: {
                HStack(spacing: 14) {
                    HIGIcon(systemName: "video.fill", color: .purple)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("addnote.attachments.video.label")
                            .foregroundColor(.primary)
                        if let videoURL = selectedVideoURL {
                            Text(videoURL.lastPathComponent)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                    if selectedVideoURL != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }
                }
            }

            // File
            NavigationLink {
                AddFileView(selectedFileURL: $selectedFileURL)
            } label: {
                HStack(spacing: 14) {
                    HIGIcon(systemName: "paperclip", color: Color(.systemGray))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("addnote.attachments.file.label")
                            .foregroundColor(.primary)
                        if let fileURL = selectedFileURL {
                            Text(fileURL.lastPathComponent)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                    if selectedFileURL != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 16))
                    }
                }
            }
        } header: {
            Text("addnote.attachments.title")
        }
    }

    var body: some View {
        Form {
            noteDetailsSection
            dateTimeSection
            customizationSection
            attachmentsSection
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .tint(themeManager.theme.color)
        .navigationBarTitle(editingNote == nil ? "addnote.newnote.title" : "stickynote.edit", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    showAddNote = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeManager.theme.color)
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    saveNote()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeManager.theme.color)
                        .symbolRenderingMode(.hierarchical)
                }
            }
        }
        .alert("common.error.validation", isPresented: $showValidationAlert) {
            Button("common.ok") { }
        } message: {
            Text(LocalizedStringKey(validationMessage))
        }
        .alert("common.success.scheduled", isPresented: $showFutureNoteAlert) {
            Button("common.ok") { showAddNote = false }
        } message: {
            Text("addnote.datetime.active")
        }
    }
}

// MARK: - Supporting Row Views

struct CategoryRowView: View {
    let category: NoteCategory

    var body: some View {
        Label(LocalizedStringKey(category.rawValue), systemImage: category.systemImage)
    }
}

struct PriorityRowView: View {
    let priority: Priority

    var body: some View {
        Label(LocalizedStringKey(priority.rawValue), systemImage: priority.systemImage)
    }
}
