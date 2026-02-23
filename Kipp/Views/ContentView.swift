//
//  ContentView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: NotesViewModel
    @State private var showAddNote = false
    @State private var editingNote: StickyNote?
    @State private var showFilters = false
    @State private var showSettings = false
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
                .navigationTitle(showingArchivedNotes ? LocalizedStringKey("home.tab.archive") : LocalizedStringKey("home.tab.mynotes"))
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        if isSelecting {
                            Button("common.cancel") {
                                isSelecting = false
                                selectedNoteIDs.removeAll()
                            }
                            .foregroundColor(themeManager.theme.color)
                        } else {
                            Button("common.edit") {
                                isSelecting = true
                            }
                            .foregroundColor(themeManager.theme.color)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if isSelecting {
                            let currentNotes = showingArchivedNotes ? viewModel.archivedNotes : viewModel.filteredNotes
                            let allSelected = !currentNotes.isEmpty && selectedNoteIDs.count == currentNotes.count
                            
                            Button(allSelected ? "Deselect All" : "Select All") {
                                if allSelected {
                                    selectedNoteIDs.removeAll()
                                } else {
                                    selectedNoteIDs = Set(currentNotes.map { $0.id })
                                }
                            }
                            .foregroundColor(themeManager.theme.color)
                        } else {
                            HStack(spacing: 16) {
                                filterButton
                                Button(action: { showSettings = true }) {
                                    Image(systemName: "gearshape")
                                        .font(.system(size: 20))
                                        .foregroundColor(themeManager.theme.color)
                                }
                            }
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .onAppear {
                    NotificationManager.shared.requestNotificationPermission()
                }

                if isSelecting && !selectedNoteIDs.isEmpty {
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Text(String(format: String(localized: "common.delete.count"), "\(selectedNoteIDs.count)"))
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
                        Button("common.delete", role: .destructive) {
                            viewModel.deleteNotes(withIDs: selectedNoteIDs)
                            isSelecting = false
                            selectedNoteIDs.removeAll()
                        }
                        Button("common.cancel", role: .cancel) {}
                    } message: {
                        Text("common.delete.confirm")
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
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
                
                TextField("common.search", text: $viewModel.searchQuery)
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
                    .stroke(isSearchFocused ? themeManager.theme.color : Color.clear, lineWidth: 1)
            )
            
            if !viewModel.searchQuery.isEmpty {
                Button("common.cancel") {
                    viewModel.searchQuery = ""
                    isSearchFocused = false
                }
                .foregroundColor(themeManager.theme.color)
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
                        color: themeManager.theme.color
                    ) {
                        viewModel.selectedCategoryFilter = nil
                    }
                }
                
                if viewModel.showOnlyWithAttachments {
                    FilterChip(
                        title: "With Attachments",
                        systemImage: "paperclip",
                        color: themeManager.theme.color
                    ) {
                        viewModel.showOnlyWithAttachments = false
                    }
                }
                
                if viewModel.showOnlyWithReminders {
                    FilterChip(
                        title: "With Reminders",
                        systemImage: "bell",
                        color: themeManager.theme.color
                    ) {
                        viewModel.showOnlyWithReminders = false
                    }
                }
                
                if viewModel.dateFilterOption != .all {
                    FilterChip(
                        title: viewModel.dateFilterOption.rawValue,
                        systemImage: viewModel.dateFilterOption.systemImage,
                        color: themeManager.theme.color
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
                                .background(themeManager.theme.color)
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
    
    private func getEmptyStateTitle() -> LocalizedStringKey {
        if showingArchivedNotes {
            return viewModel.searchQuery.isEmpty ? "home.empty.archive" : "home.empty.search.title"
        } else {
            return viewModel.searchQuery.isEmpty ? "home.empty.notes.title" : "home.empty.search.title"
        }
    }
    
    private func getEmptyStateMessage() -> LocalizedStringKey {
        if showingArchivedNotes {
            return viewModel.searchQuery.isEmpty ? "home.empty.archive.desc" : "home.empty.search.desc"
        } else {
            return viewModel.searchQuery.isEmpty ? "home.empty.notes.desc" : "home.empty.search.desc"
        }
    }
    
    // MARK: - Filter Button
    private var filterButton: some View {
        Button(action: {
            showFilters = true
        }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 20))
                .foregroundColor(themeManager.theme.color)
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
            
            Text(LocalizedStringKey(title))
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
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(LocalizedStringKey(title))
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? themeManager.theme.color : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct FilterView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var viewModel: NotesViewModel
    @Binding var showingArchivedNotes: Bool
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showResetConfirmation = false
    @State private var showCustomCategoryAlert = false
    @State private var customCategoryInput = ""
    @State private var previousCategory: NoteCategory? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("View", selection: $showingArchivedNotes) {
                Text("home.tab.mynotes").tag(false)
                Text("home.tab.archive").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .tint(themeManager.theme.color)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGroupedBackground))
            
            Form {
                Section(header: Text("addnote.category")) {
                    Picker("addnote.category", selection: Binding(
                        get: { viewModel.selectedCategoryFilter },
                        set: { newValue in
                            if let newValue = newValue, case .custom = newValue {
                                previousCategory = viewModel.selectedCategoryFilter
                                customCategoryInput = ""
                                showCustomCategoryAlert = true
                            } else {
                                viewModel.selectedCategoryFilter = newValue
                            }
                        }
                    )) {
                        Text("home.filters.category.all").tag(nil as NoteCategory?)
                        Divider()
                        ForEach(NoteCategory.allCases, id: \.id) { category in
                            CategoryRowView(category: category)
                                .tag(category as NoteCategory?)
                        }
                        Divider()
                        Text("home.filters.category.custom").tag(NoteCategory.custom("") as NoteCategory?)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .tint(themeManager.theme.color)
                    .alert("home.filters.category.custom.alert", isPresented: $showCustomCategoryAlert, actions: {
                        TextField("home.filters.category.custom.placeholder", text: $customCategoryInput)
                        Button("common.ok") {
                            if !customCategoryInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                viewModel.selectedCategoryFilter = .custom(customCategoryInput.trimmingCharacters(in: .whitespacesAndNewlines))
                            } else {
                                viewModel.selectedCategoryFilter = previousCategory
                            }
                        }
                        Button("common.cancel", role: .cancel) {
                            viewModel.selectedCategoryFilter = previousCategory
                        }
                    }, message: {
                        Text("home.filters.category.custom.message")
                    })
                }
                
                Section(header: Text("home.filters.date")) {
                    Picker("home.filters.date", selection: $viewModel.dateFilterOption) {
                        HStack {
                            Text(LocalizedStringKey(NotesViewModel.DateFilterOption.all.rawValue))
                            Spacer()
                            Image(systemName: NotesViewModel.DateFilterOption.all.systemImage)
                                .foregroundColor(themeManager.theme.color)
                        }
                        .tag(NotesViewModel.DateFilterOption.all)
                        Divider()
                        ForEach(NotesViewModel.DateFilterOption.allCases.filter { $0 != .all }, id: \.self) { option in
                            HStack {
                                Text(LocalizedStringKey(option.rawValue))
                                Spacer()
                                Image(systemName: option.systemImage)
                                    .foregroundColor(themeManager.theme.color)
                            }
                            .tag(option)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("home.filters.content")) {
                    Toggle("home.filters.content.attachments", isOn: $viewModel.showOnlyWithAttachments)
                    Toggle("home.filters.content.reminders", isOn: $viewModel.showOnlyWithReminders)
                }
            }
            .tint(themeManager.theme.color)
        }
        .navigationTitle("home.filters.title")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("common.reset") {
                    viewModel.selectedCategoryFilter = nil
                    viewModel.showOnlyWithAttachments = false
                    viewModel.showOnlyWithReminders = false
                    viewModel.dateFilterOption = .all
                }
                .foregroundColor(themeManager.theme.color)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("common.done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(themeManager.theme.color)
            }
        }
    }
}

