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
    @State private var showFilters = false
    @State private var isSearchFocused = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Modern Search Bar
                searchBar
                
                // Filter Chips
                if hasActiveFilters {
                    filterChips
                }
                
                // Sort Options
                sortOptions
                
                // Notes List
                notesList
            }
            .navigationTitle("My Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showAddNote, onDismiss: { editingNote = nil }) {
                AddNoteView(
                    viewModel: viewModel,
                    showAddNote: $showAddNote,
                    editingNote: editingNote
                )
            }
            .sheet(isPresented: $showFilters) {
                FilterView(viewModel: viewModel)
            }
            .onAppear {
                NotificationManager.shared.requestNotificationPermission()
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
                    .stroke(isSearchFocused ? Color.blue : Color.clear, lineWidth: 1)
            )
            
            if !viewModel.searchQuery.isEmpty {
                Button("Cancel") {
                    viewModel.searchQuery = ""
                    isSearchFocused = false
                }
                .foregroundColor(.blue)
                .font(.system(size: 16, weight: .medium))
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
                        color: .blue
                    ) {
                        viewModel.selectedCategoryFilter = nil
                    }
                }
                
                if viewModel.showOnlyWithAttachments {
                    FilterChip(
                        title: "With Attachments",
                        systemImage: "paperclip",
                        color: .green
                    ) {
                        viewModel.showOnlyWithAttachments = false
                    }
                }
                
                if viewModel.showOnlyWithReminders {
                    FilterChip(
                        title: "With Reminders",
                        systemImage: "bell",
                        color: .orange
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
            if viewModel.filteredNotes.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.filteredNotes, id: \.id) { note in
                            StickyNoteView(
                                note: note,
                                markAsDone: { viewModel.markAsDone(id: note.id) },
                                onEdit: {
                                    editingNote = note
                                    showAddNote = true
                                },
                                onDelete: { viewModel.deleteNote(id: note.id) }
                            )
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // Floating Add Button
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
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(viewModel.searchQuery.isEmpty ? "No Notes Yet" : "No Results Found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(viewModel.searchQuery.isEmpty ? "Tap the + button to create your first note" : "Try adjusting your search or filters")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Filter Button
    private var filterButton: some View {
        Button(action: {
            showFilters = true
        }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 20))
                .foregroundColor(hasActiveFilters ? .blue : .primary)
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
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct FilterView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Category")) {
                    Picker("Category", selection: $viewModel.selectedCategoryFilter) {
                        Text("All Categories").tag(nil as NoteCategory?)
                        ForEach(NoteCategory.allCases) { category in
                            HStack {
                                Text(category.rawValue)
                                Spacer()
                                Image(systemName: category.systemImage)
                                    .foregroundColor(.blue)
                            }
                            .tag(category as NoteCategory?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Date Range")) {
                    Picker("Date Filter", selection: $viewModel.dateFilterOption) {
                        ForEach(NotesViewModel.DateFilterOption.allCases, id: \.self) { option in
                            HStack {
                                Text(option.rawValue)
                                Spacer()
                                Image(systemName: option.systemImage)
                                    .foregroundColor(.blue)
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
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
