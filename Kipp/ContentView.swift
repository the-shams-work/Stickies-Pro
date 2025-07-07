//
//  ContentView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: NotesViewModel
    @State private var showAddNote = false
    @State private var editingNote: StickyNote?
    @State private var showFilters = false
    @State private var isSearchFocused = false
    @State private var showingArchivedNotes = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var isSelecting = false
    @State private var selectedNoteIDs = Set<UUID>()
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    searchBar
                    
                    if hasActiveFilters {
                        filterChips
                    }
                    sortOptions
                    notesList
                }
                .navigationTitle(showingArchivedNotes ? "Archive" : "My Notes")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if isSelecting {
                            Button("Cancel") {
                                isSelecting = false
                                selectedNoteIDs.removeAll()
                            }
                            .foregroundColor(.purple)
                        } else {
                            Button("Edit") {
                                isSelecting = true
                            }
                            .foregroundColor(.purple)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        filterButton
                    }
                }
                .background(Color(.systemGroupedBackground))
                .onAppear {
                    NotificationManager.shared.requestNotificationPermission()
                }

                // Floating Delete Button Overlay
                if isSelecting && !selectedNoteIDs.isEmpty {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Text("Delete (\(selectedNoteIDs.count))")
                            .font(.headline)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(22)
                            .shadow(color: Color.black.opacity(0.12), radius: 2, y: 1)
                    }
                    .padding(.bottom, 24)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: isSelecting)
                    .alert("Delete Notes?", isPresented: $showDeleteAlert) {
                        Button("Delete", role: .destructive) {
                            viewModel.deleteNotes(withIDs: selectedNoteIDs)
                            isSelecting = false
                            selectedNoteIDs.removeAll()
                        }
                        Button("Cancel", role: .cancel) {}
                    } message: {
                        Text("Are you sure you want to delete the selected notes? This action cannot be undone.")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddNote, onDismiss: { editingNote = nil }) {
            NavigationStack {
                AddNoteView(
                    viewModel: viewModel,
                    showAddNote: $showAddNote,
                    editingNote: editingNote
                )
            }
        }
        .sheet(isPresented: $showFilters) {
            NavigationStack {
                FilterView(viewModel: viewModel, showingArchivedNotes: $showingArchivedNotes)
            }
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search notes...", text: $viewModel.searchQuery)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .onTapGesture {
                        isSearchFocused = true
                    }
                
                if !viewModel.searchQuery.isEmpty {
                    Button(action: {
                        viewModel.searchQuery = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSearchFocused ? Color.purple : Color.clear, lineWidth: 1)
            )
            
            if !viewModel.searchQuery.isEmpty {
                Button("Cancel") {
                    viewModel.searchQuery = ""
                    isSearchFocused = false
                }
                .foregroundColor(.purple)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Filter Chips
    private var hasActiveFilters: Bool {
        viewModel.selectedCategoryFilter != nil ||
        viewModel.showOnlyWithAttachments ||
        viewModel.showOnlyWithReminders ||
        viewModel.dateFilterOption != .all
    }
    
    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if let category = viewModel.selectedCategoryFilter {
                    FilterChip(
                        title: category.rawValue,
                        systemImage: category.systemImage,
                        color: .purple
                    ) {
                        viewModel.selectedCategoryFilter = nil
                    }
                }
                
                if viewModel.showOnlyWithAttachments {
                    FilterChip(
                        title: "With Attachments",
                        systemImage: "paperclip",
                        color: .purple
                    ) {
                        viewModel.showOnlyWithAttachments = false
                    }
                }
                
                if viewModel.showOnlyWithReminders {
                    FilterChip(
                        title: "With Reminders",
                        systemImage: "bell",
                        color: .purple
                    ) {
                        viewModel.showOnlyWithReminders = false
                    }
                }
                
                if viewModel.dateFilterOption != .all {
                    FilterChip(
                        title: viewModel.dateFilterOption.rawValue,
                        systemImage: viewModel.dateFilterOption.systemImage,
                        color: .purple
                    ) {
                        viewModel.dateFilterOption = .all
                    }
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Sort Options
    private var sortOptions: some View {
        HStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    SortButton(title: "Recent", isSelected: viewModel.sortOption == .dateCreated) {
                        viewModel.sortOption = .dateCreated
                    }
                    
                    SortButton(title: "Title", isSelected: viewModel.sortOption == .title) {
                        viewModel.sortOption = .title
                    }
                    
                    SortButton(title: "Category", isSelected: viewModel.sortOption == .category) {
                        viewModel.sortOption = .category
                    }
                    
                    SortButton(title: "Priority", isSelected: viewModel.sortOption == .priority) {
                        viewModel.sortOption = .priority
                    }
                }
                .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Notes List
    private var notesList: some View {
        ZStack {
            let currentNotes = showingArchivedNotes ? viewModel.archivedNotes : viewModel.filteredNotes
            
            if currentNotes.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(currentNotes, id: \.id) { note in
                            StickyNoteView(
                                note: note,
                                markAsDone: { viewModel.markAsDone(id: note.id) },
                                onEdit: {
                                    if !showingArchivedNotes && !isSelecting {
                                        editingNote = note
                                        showAddNote = true
                                    }
                                },
                                onDelete: { viewModel.deleteNote(id: note.id) },
                                isSelecting: isSelecting,
                                isSelected: selectedNoteIDs.contains(note.id)
                            )
                            .padding(.horizontal, 16)
                            .onTapGesture {
                                if isSelecting {
                                    if selectedNoteIDs.contains(note.id) {
                                        selectedNoteIDs.remove(note.id)
                                    } else {
                                        selectedNoteIDs.insert(note.id)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // Floating Add Button (only show for active notes)
            if !showingArchivedNotes {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            editingNote = nil
                            showAddNote = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Color.purple)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: showingArchivedNotes ? "clock" : "note.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(getEmptyStateTitle())
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(getEmptyStateMessage())
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func getEmptyStateTitle() -> String {
        if showingArchivedNotes {
            return viewModel.searchQuery.isEmpty ? "No Archived Notes" : "No Results Found"
        } else {
            return viewModel.searchQuery.isEmpty ? "No Notes Yet" : "No Results Found"
        }
    }
    
    private func getEmptyStateMessage() -> String {
        if showingArchivedNotes {
            return viewModel.searchQuery.isEmpty ? "Completed notes will appear here" : "Try adjusting your search or filters"
        } else {
            return viewModel.searchQuery.isEmpty ? "Tap the + button to create your note" : "Try adjusting your search or filters"
        }
    }
    
    // MARK: - Filter Button
    private var filterButton: some View {
        Button(action: {
            showFilters = true
        }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 20))
                .foregroundColor(hasActiveFilters ? .purple : .primary)
        }
    }
}

// MARK: - Supporting Views
struct FilterChip: View {
    let title: String
    let systemImage: String
    let color: Color
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.system(size: 12, weight: .medium))
            
            Text(title)
                .font(.system(size: 14, weight: .medium))
            
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .foregroundColor(color)
        .cornerRadius(16)
    }
}

struct SortButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.purple : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct FilterView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Binding var showingArchivedNotes: Bool
    @Environment(\.presentationMode) var presentationMode
    
    // Reset confirmation state
    @State private var showResetConfirmation = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Control for View Switching
            Picker("View", selection: $showingArchivedNotes) {
                Text("My Notes").tag(false)
                Text("Archive").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .tint(.purple)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGroupedBackground))
            
            Form {
                Section(header: Text("Category")) {
                    Picker("Category", selection: $viewModel.selectedCategoryFilter) {
                        Text("All Categories").tag(nil as NoteCategory?)
                        Divider()
                        ForEach(NoteCategory.allCases) { category in
                            CategoryRowView(category: category)
                                .tag(category as NoteCategory?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .tint(.purple)
                }
                
                Section(header: Text("Date Range")) {
                    Picker("Date Filter", selection: $viewModel.dateFilterOption) {
                        ForEach(NotesViewModel.DateFilterOption.allCases, id: \.self) { option in
                            HStack {
                                Text(option.rawValue)
                                Spacer()
                                Image(systemName: option.systemImage)
                                    .foregroundColor(.purple)
                            }
                            .tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Content Type")) {
                    Toggle("Only notes with attachments", isOn: $viewModel.showOnlyWithAttachments)
                    Toggle("Only notes with reminders", isOn: $viewModel.showOnlyWithReminders)
                }
            }
            .tint(.purple)
        }
        .navigationTitle("Filters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Reset") {
                    viewModel.selectedCategoryFilter = nil
                    viewModel.showOnlyWithAttachments = false
                    viewModel.showOnlyWithReminders = false
                    viewModel.dateFilterOption = .all
                }
                .foregroundColor(.purple)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.purple)
            }
        }
    }
}

