//
//  AddNoteView.swift
//  Stickies Pro
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import AVKit
import Speech

struct AddNoteView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Binding var showAddNote: Bool
    
    var editingNote: StickyNote?
    
    @State private var title: String
    @State private var content: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedColor: Color
    @State private var selectedCategory: NoteCategory
    @State private var selectedImage: UIImage?
    @State private var selectedAudioURL: URL?
    @State private var selectedVideoURL: URL?
    @State private var reminderDate: Date?

    @State private var showImagePicker = false
    @State private var showAudioPicker = false
    @State private var showVideoPicker = false

    @State private var isRecording = false
    @StateObject private var speechRecognizer = SpeechRecognizer()

    let today = Date()

    init(viewModel: NotesViewModel, showAddNote: Binding<Bool>, editingNote: StickyNote? = nil) {
        self.viewModel = viewModel
        self._showAddNote = showAddNote
        self.editingNote = editingNote
        
        _title = State(initialValue: editingNote?.title ?? "")
        _content = State(initialValue: editingNote?.content ?? "")
        _startDate = State(initialValue: editingNote?.startDate ?? Date())
        _endDate = State(initialValue: editingNote?.endDate ?? Date())
        _selectedColor = State(initialValue: editingNote?.color ?? .yellow)
        _selectedCategory = State(initialValue: editingNote?.category ?? .todo)
        _selectedImage = State(initialValue: editingNote?.attachment)
        _selectedAudioURL = State(initialValue: editingNote?.audioURL)
        _selectedVideoURL = State(initialValue: editingNote?.videoURL)
        _reminderDate = State(initialValue: editingNote?.reminderDate)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Details")) {
                    TextField("Title", text: $title)

                    HStack(alignment: .top) {
                        TextField("Body", text: $content, axis: .vertical)
                            .lineLimit(5, reservesSpace: true)

                        Button(action: {
                            if isRecording {
                                speechRecognizer.stopTranscribing()
                            } else {
                                speechRecognizer.startTranscribing { transcribedText in
                                    self.content = transcribedText
                                }
                            }
                            isRecording.toggle()
                        }) {
                            Image(systemName: isRecording ? "mic.fill" : "mic")
                                .foregroundColor(isRecording ? .red : .purple)
                                .padding(.top, 5)
                                .padding(.leading, 3)
                        }
                    }
                }

                Section(header: Text("Date & Time")) {
                    DatePicker("Start Date", selection: $startDate, in: today..., displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    DatePicker("Set Reminder", selection: Binding(
                        get: { reminderDate ?? today },
                        set: { reminderDate = $0 }
                    ), in: today..., displayedComponents: [.date, .hourAndMinute])
                }

                Section(header: Text("Customization")) {
                    ColorPicker("Note Color", selection: $selectedColor)

                    Picker("Category", selection: $selectedCategory) {
                        ForEach(NoteCategory.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
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
            .navigationBarTitle(editingNote == nil ? "New Sticky Note" : "Edit Sticky Note", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { showAddNote = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if let editingNote {
                            viewModel.updateNote(
                                id: editingNote.id,
                                title: title,
                                content: content,
                                startDate: startDate,
                                endDate: endDate,
                                color: selectedColor,
                                category: selectedCategory,
                                attachment: selectedImage,
                                audioURL: selectedAudioURL,
                                videoURL: selectedVideoURL,
                                reminderDate: reminderDate
                            )

                            if let reminderDate = reminderDate {
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
                                startDate: startDate,
                                endDate: endDate,
                                color: selectedColor,
                                category: selectedCategory,
                                attachment: selectedImage,
                                audioURL: selectedAudioURL,
                                videoURL: selectedVideoURL,
                                reminderDate: reminderDate
                            )

                            if let reminderDate = reminderDate, reminderDate > Date() {
                                NotificationManager.shared.scheduleNotification(
                                    title: "Reminder: \(title)",
                                    body: content,
                                    date: reminderDate,
                                    identifier: newNote.id.uuidString
                                )
                            }
                        }
                        showAddNote = false
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

