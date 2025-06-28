//
//  ContentView.swift
//  Stickies Pro
//
//  Created by Shams Tabrej Alam on 13/02/25.
//
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var showAddNote = false
    @State private var editingNote: StickyNote?
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var activeNotes: [StickyNote] {
        var notes = viewModel.notes.filter { !$0.isDone && $0.startDate <= Date() }
        
        if !viewModel.searchQuery.isEmpty {
            notes = notes.filter {
                $0.title.localizedCaseInsensitiveContains(viewModel.searchQuery) ||
                $0.content.localizedCaseInsensitiveContains(viewModel.searchQuery)
            }
        }
        
        switch viewModel.sortOption {
        case .dateCreated:
            notes.sort { $0.startDate > $1.startDate }
        case .title:
            notes.sort { $0.title.lowercased() < $1.title.lowercased() }
        case .category:
            notes.sort { $0.category.rawValue < $1.category.rawValue }
        }
        
        return notes
    }

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 10)
                        
                        TextField("Search notes...", text: $viewModel.searchQuery)
                            .padding(5)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .foregroundColor(.primary)
                            .font(.body)
                            .disableAutocorrection(true)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)

                    Picker("Sort by", selection: $viewModel.sortOption) {
                        Text("Date Created").tag(NotesViewModel.SortOption.dateCreated)
                        Text("Title").tag(NotesViewModel.SortOption.title)
                        Text("Category").tag(NotesViewModel.SortOption.category)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)

                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(activeNotes, id: \.id) { note in
                                StickyNoteView(
                                    note: note,
                                    markAsDone: { viewModel.markAsDone(id: note.id) },
                                    onEdit: {
                                        editingNote = note
                                        showAddNote = true
                                    },
                                    onDelete: { viewModel.deleteNote(id: note.id) }
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .navigationTitle("My Notes")

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            editingNote = nil
                            showAddNote = true
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .padding()
                                .background(Color.purple)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
            .onAppear {
                NotificationManager.shared.requestNotificationPermission()
            }
            .sheet(isPresented: $showAddNote, onDismiss: { editingNote = nil }) {
                AddNoteView(
                    viewModel: viewModel,
                    showAddNote: $showAddNote,
                    editingNote: editingNote
                )
            }
        }
    }
}
