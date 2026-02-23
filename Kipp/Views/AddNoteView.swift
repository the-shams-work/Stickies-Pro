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
    @State private var showCustomCategoryAlert = false
    @State private var customCategoryInput = ""
    @State private var previousCategory: NoteCategory? = nil
    @State private var showRemoveImageAlert = false
    @State private var showRemoveAudioAlert = false
    @State private var showRemoveVideoAlert = false
    @State private var showRemoveBackgroundImageAlert = false
    @State private var isPickingBackgroundImage = false
    @State private var showBackgroundImagePicker = false
    @State private var showImageMenu = false
    @State private var showAudioMenu = false
    @State private var showVideoMenu = false
    @State private var showImagePicker = false
    @State private var showVideoPicker = false
    @State private var showAudioPicker = false
    @State private var showAudioRecorder = false
    @State private var isRecording = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordingURL: URL?
    @State private var imageCoordinator: ImmersiveCameraCoordinator?
    @State private var videoCoordinator: ImmersiveVideoCoordinator?

    let today = Date()

    init(viewModel: NotesViewModel, showAddNote: Binding<Bool>, editingNote: StickyNote? = nil) {
        self.viewModel = viewModel
        self._showAddNote = showAddNote
        self.editingNote = editingNote
        
        _title = State(initialValue: editingNote?.title ?? "")
        _content = State(initialValue: editingNote?.content ?? "")
        _startDate = State(initialValue: editingNote?.startDate ?? Date())
        _endDate = State(initialValue: editingNote?.endDate ?? Date())
        _selectedColor = State(initialValue: editingNote?.colorValue ?? Color.white)
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
                backgroundImage: selectedBackgroundImage,
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
                backgroundImage: selectedBackgroundImage,
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
    
    // MARK: - Attachment Helper Functions
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        if sourceType == .camera {
            guard let topVC = UIApplication.topViewController() else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            let newCoordinator = ImmersiveCameraCoordinator(
                onImagePicked: { image in
                    selectedImage = image
                },
                onDismiss: {}
            )
            picker.delegate = newCoordinator
            imageCoordinator = newCoordinator
            topVC.present(picker, animated: true)
        } else if sourceType == .photoLibrary {
            showImagePicker = true
        }
    }
    
    private func presentVideoPicker(sourceType: UIImagePickerController.SourceType) {
        if sourceType == .camera {
            guard let topVC = UIApplication.topViewController() else { return }
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeHigh
            let newCoordinator = ImmersiveVideoCoordinator(
                onVideoPicked: { url in
                    selectedVideoURL = url
                },
                onDismiss: {}
            )
            picker.delegate = newCoordinator
            videoCoordinator = newCoordinator
            topVC.present(picker, animated: true)
        } else if sourceType == .photoLibrary {
            showVideoPicker = true
        }
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    showAudioRecorder = true
                } else {
                }
            }
        }
    }

    @ViewBuilder
    private var noteDetailsSection: some View {
        Section(header: Text("addnote.details")) {
            TextField("addnote.title.field", text: $title)
            TextField("addnote.content.field",text: $content, axis: .vertical)
                .lineLimit(5, reservesSpace: true)
        }
    }

    @ViewBuilder
    private var dateTimeSection: some View {
        Section(header: Text("addnote.datetime"), footer: isTimeBounded ? AnyView(
            Text("addnote.datetime.info")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        ) : AnyView(EmptyView())) {
            Toggle("home.filters.date", isOn: Binding(
                get: { isTimeBounded },
                set: { newValue in
                    isTimeBounded = newValue
                    if !newValue {
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
                DatePicker("addnote.datetime", selection: Binding(
                    get: { reminderDate ?? today },
                    set: { reminderDate = $0 }
                ), in: today..., displayedComponents: [.date, .hourAndMinute])
                Picker("addnote.reminders.repeat", selection: $selectedRepeat) {
                    Text("Never").tag(ReminderRepeat.never)
                    Divider()
                    ForEach(ReminderRepeat.allCases.filter { $0 != .never }) { repeatOption in
                        Text(LocalizedStringKey(repeatOption.rawValue)).tag(repeatOption)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var customizationSection: some View {
        Section(header: Text("addnote.customization")) {
            ColorRowView(selectedColor: $selectedColor)
            
            Menu {
                Button {
                    if let topVC = UIApplication.topViewController() {
                        let picker = UIImagePickerController()
                        picker.sourceType = .camera
                        let newCoordinator = ImmersiveCameraCoordinator(
                            onImagePicked: { image in
                                selectedBackgroundImage = image
                            },
                            onDismiss: {}
                        )
                        picker.delegate = newCoordinator
                        imageCoordinator = newCoordinator
                        topVC.present(picker, animated: true)
                    }
                } label: {
                    Label("addnote.attachments.camera", systemImage: "camera")
                }
                Button {
                    showBackgroundImagePicker = true
                } label: {
                    Label("addnote.attachments.library", systemImage: "photo.on.rectangle")
                }
            } label: {
                HStack {
                    Text("addnote.background")
                        .foregroundColor(Color(UIColor.label))
                    Spacer()
                    Image(systemName: "photo.artframe")
                        .resizable()
                        .frame(width: 24, height: 20)
                        .foregroundColor(themeManager.theme.color)
                }
                .contentShape(Rectangle())
            }
            if let backgroundImage = selectedBackgroundImage {
                Image(uiImage: backgroundImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .onTapGesture {
                        showRemoveBackgroundImageAlert = true
                    }
                    .confirmationDialog("Remove Background Image?", isPresented: $showRemoveBackgroundImageAlert, titleVisibility: .visible) {
                        Button("common.remove", role: .destructive) { selectedBackgroundImage = nil }
                        Button("common.cancel", role: .cancel) { }
                    } message: {
                        Text("addnote.background.remove.message")
                    }
            }

            Picker("addnote.priority", selection: $selectedPriority) {
                Text("None").tag(Priority.none)
                Divider()
                ForEach(Priority.allCases.filter { $0 != .none }) { priority in
                    PriorityRowView(priority: priority)
                        .tag(priority)
                }
            }
            .tint(themeManager.theme.color)
            
            Picker("addnote.category", selection: Binding(
                get: { selectedCategory },
                set: { newValue in
                    if let newValue = newValue, case .custom = newValue {
                        previousCategory = selectedCategory
                        customCategoryInput = ""
                        showCustomCategoryAlert = true
                    } else {
                        selectedCategory = newValue
                    }
                }
            )) {
                Text("addnote.category.select").tag(nil as NoteCategory?)
                Divider()
                ForEach(NoteCategory.allCases, id: \.id) { category in
                    CategoryRowView(category: category)
                        .tag(category as NoteCategory?)
                }
                Divider()
                Text("home.filters.category.custom").tag(NoteCategory.custom("") as NoteCategory?)
            }
            .tint(themeManager.theme.color)
        }
    }

    @ViewBuilder
    private var attachmentsSection: some View {
        Section(header: Text("addnote.attachments.title")) {
            Menu {
                Button {
                    presentImagePicker(sourceType: .camera)
                } label: {
                    Label("addnote.attachments.camera", systemImage: "camera")
                }
                Button {
                    showImagePicker = true
                } label: {
                    Label("addnote.attachments.library", systemImage: "photo.on.rectangle")
                }
            } label: {
                AttachmentRowView(
                    title: "Image",
                    systemIcon: "photo.fill",
                    hasAttachment: selectedImage != nil,
                    onTap: {}
                )
            }
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .cornerRadius(8)
                    .onLongPressGesture {
                        showRemoveImageAlert = true
                    }
                    .confirmationDialog("addnote.attachments.image.remove.title", isPresented: $showRemoveImageAlert, titleVisibility: .visible) {
                        Button("common.remove", role: .destructive) { selectedImage = nil }
                        Button("common.cancel", role: .cancel) { }
                    } message: {
                        Text("addnote.attachments.image.remove.message")
                    }
            }

            // Audio Attachment
            Menu {
                Button {
                    requestMicrophonePermission()
                } label: {
                    Label("addnote.attachments.audio.record", systemImage: "mic")
                }
                Button {
                    showAudioPicker = true
                } label: {
                    Label("addnote.attachments.audio.file", systemImage: "music.note.list")
                }
            } label: {
                AttachmentRowView(
                    title: "Audio",
                    systemIcon: "music.note",
                    hasAttachment: selectedAudioURL != nil,
                    onTap: {}
                )
            }
            if let audioURL = selectedAudioURL {
                Text(String(localized: "addnote.attachments.audio.label") + ": " + audioURL.lastPathComponent)
                    .onLongPressGesture {
                        showRemoveAudioAlert = true
                    }
                    .confirmationDialog("addnote.attachments.audio.remove.title", isPresented: $showRemoveAudioAlert, titleVisibility: .visible) {
                        Button("common.remove", role: .destructive) { selectedAudioURL = nil }
                        Button("common.cancel", role: .cancel) { }
                    } message: {
                        Text("addnote.attachments.audio.remove.message")
                    }
            }

            Menu {
                Button {
                    presentVideoPicker(sourceType: .camera)
                } label: {
                    Label("addnote.attachments.camera", systemImage: "video")
                }
                Button {
                    showVideoPicker = true
                } label: {
                    Label("addnote.attachments.library", systemImage: "film")
                }
            } label: {
                AttachmentRowView(
                    title: "Video",
                    systemIcon: "video.fill",
                    hasAttachment: selectedVideoURL != nil,
                    onTap: {}
                )
            }
            if let videoURL = selectedVideoURL {
                Text(String(localized: "addnote.attachments.video.label") + ": " + videoURL.lastPathComponent)
                    .onLongPressGesture {
                        showRemoveVideoAlert = true
                    }
                    .confirmationDialog("addnote.attachments.video.remove.title", isPresented: $showRemoveVideoAlert, titleVisibility: .visible) {
                        Button("common.remove", role: .destructive) { selectedVideoURL = nil }
                        Button("common.cancel", role: .cancel) { }
                    } message: {
                        Text("addnote.attachments.video.remove.message")
                    }
            }
        }
    }

    var body: some View {
        Form {
            noteDetailsSection
            dateTimeSection
            customizationSection
            attachmentsSection
        }
        .tint(themeManager.theme.color)
        .navigationBarTitle(editingNote == nil ? "New Note" : "Edit Sticky Note", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("common.cancel") { 
                    showAddNote = false 
                }
                .foregroundColor(themeManager.theme.color)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("common.save") {
                    saveNote()
                }
                .foregroundColor(themeManager.theme.color)
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
        .alert("home.filters.category.custom.alert", isPresented: $showCustomCategoryAlert, actions: {
            TextField("home.filters.category.custom.placeholder", text: $customCategoryInput)
            Button("common.ok") {
                if !customCategoryInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    selectedCategory = .custom(customCategoryInput.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    selectedCategory = previousCategory
                }
            }
            Button("common.cancel", role: .cancel) {
                selectedCategory = previousCategory
            }
        }, message: {
            Text("home.filters.category.custom.message")
        })
        .sheet(isPresented: $showBackgroundImagePicker) {
            ImagePicker(image: $selectedBackgroundImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showVideoPicker) {
            VideoPicker(videoURL: $selectedVideoURL, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showAudioPicker) {
            MediaPicker(mediaType: .audio, mediaURL: $selectedAudioURL)
        }
        .sheet(isPresented: $showAudioRecorder) {
            AudioRecorderView(
                isRecording: $isRecording,
                audioRecorder: $audioRecorder,
                recordingURL: $recordingURL,
                selectedAudioURL: $selectedAudioURL
            )
        }
        .tint(themeManager.theme.color)
    }
}

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

struct ColorRowView: View {
    @Binding var selectedColor: Color

    var body: some View {
        HStack {
            Text("addnote.color")
            Spacer()
            ColorPicker("", selection: $selectedColor)
                .labelsHidden()
        }
    }
}

struct AttachmentRowView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let systemIcon: String
    let hasAttachment: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
                .foregroundColor(.primary)
            Spacer()
            Image(systemName: systemIcon)
                .resizable()
                .frame(width: 24, height: 20)
                .foregroundColor(themeManager.theme.color)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

