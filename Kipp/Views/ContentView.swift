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
    @State private var showAnalytics = false
    @State private var showingArchivedNotes = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var isSelecting = false
    @State private var selectedNoteIDs = Set<UUID>()
    @State private var showDeleteAlert = false
    @AppStorage("noteViewMode") private var isGridView: Bool = true

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
                            Button("common.select") {
                                isSelecting = true
                            }
                            .foregroundColor(themeManager.theme.color)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if isSelecting {
                            let currentNotes = showingArchivedNotes ? viewModel.archivedNotes : viewModel.filteredNotes
                            let allSelected = !currentNotes.isEmpty && selectedNoteIDs.count == currentNotes.count
                            
                            Button(allSelected ? LocalizedStringKey("common.deselect.all") : LocalizedStringKey("common.select.all")) {
                                if allSelected {
                                    selectedNoteIDs.removeAll()
                                } else {
                                    selectedNoteIDs = Set(currentNotes.map { $0.id })
                                }
                            }
                            .foregroundColor(themeManager.theme.color)
                        } else {
                            Menu {
                                Button { showAnalytics = true } label: {
                                    Label("analytics.title", systemImage: "chart.bar")
                                }
                                Button {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        isGridView.toggle()
                                    }
                                } label: {
                                    Label(
                                        isGridView ? "List View" : "Grid View",
                                        systemImage: isGridView ? "list.bullet" : "square.grid.2x2"
                                    )
                                }
                                Button { showFilters = true } label: {
                                    Label("home.filters.title", systemImage: "line.3.horizontal.decrease.circle")
                                }
                                Button { showSettings = true } label: {
                                    Label("settings.title", systemImage: "gearshape")
                                }
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(themeManager.theme.color)
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
            .navigationDestination(for: StickyNote.self) { note in
                NoteDetailView(viewModel: viewModel, note: note)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showAnalytics) {
            AnalyticsView(viewModel: viewModel)
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
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16))
            TextField(String(localized: "common.search"), text: $viewModel.searchQuery)
                .font(.body)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !viewModel.searchQuery.isEmpty {
                Button {
                    viewModel.searchQuery = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.tertiarySystemFill))
        )
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 4)
    }

    // MARK: - Sort Options
    private var sortOptions: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
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
        .padding(.vertical, 8)
    }
    
    // MARK: - Notes List
    private var notesList: some View {
        ZStack {
            let currentNotes = showingArchivedNotes ? viewModel.archivedNotes : viewModel.filteredNotes

            if currentNotes.isEmpty {
                emptyStateView
            } else if isGridView {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                        spacing: 12
                    ) {
                        ForEach(currentNotes, id: \.id) { note in
                            if isSelecting {
                                StickyNoteView(
                                    note: note,
                                    markAsDone: { viewModel.markAsDone(id: note.id) },
                                    onEdit: {
                                        if !showingArchivedNotes {
                                            editingNote = note
                                            showAddNote = true
                                        }
                                    },
                                    onDelete: { viewModel.deleteNote(id: note.id) },
                                    onTogglePin: { viewModel.togglePin(id: note.id) },
                                    isSelecting: isSelecting,
                                    isSelected: selectedNoteIDs.contains(note.id)
                                )
                                .frame(minHeight: 110, maxHeight: 160)
                                .onTapGesture {
                                    if selectedNoteIDs.contains(note.id) {
                                        selectedNoteIDs.remove(note.id)
                                    } else {
                                        selectedNoteIDs.insert(note.id)
                                    }
                                }
                            } else {
                                NavigationLink(value: note) {
                                    StickyNoteView(
                                        note: note,
                                        markAsDone: { viewModel.markAsDone(id: note.id) },
                                        onEdit: {
                                            if !showingArchivedNotes {
                                                editingNote = note
                                                showAddNote = true
                                            }
                                        },
                                        onDelete: { viewModel.deleteNote(id: note.id) },
                                        onTogglePin: { viewModel.togglePin(id: note.id) },
                                        isSelecting: isSelecting,
                                        isSelected: selectedNoteIDs.contains(note.id)
                                    )
                                    .frame(minHeight: 110, maxHeight: 160)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(currentNotes, id: \.id) { note in
                            if isSelecting {
                                NoteListRow(
                                    note: note,
                                    isSelecting: true,
                                    isSelected: selectedNoteIDs.contains(note.id)
                                )
                                .onTapGesture {
                                    if selectedNoteIDs.contains(note.id) {
                                        selectedNoteIDs.remove(note.id)
                                    } else {
                                        selectedNoteIDs.insert(note.id)
                                    }
                                }
                            } else {
                                NavigationLink(value: note) {
                                    NoteListRow(
                                        note: note,
                                        isSelecting: false,
                                        isSelected: false
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contextMenu {
                                    Button(action: { viewModel.togglePin(id: note.id) }) {
                                        Label(
                                            note.isPinned ? "stickynote.unpin" : "stickynote.pin",
                                            systemImage: note.isPinned ? "pin.slash" : "pin"
                                        )
                                    }
                                    Button(action: {
                                        if !showingArchivedNotes {
                                            editingNote = note
                                            showAddNote = true
                                        }
                                    }) {
                                        Label("common.edit", systemImage: "pencil")
                                    }
                                    Button(action: { viewModel.markAsDone(id: note.id) }) {
                                        Label(note.isDone ? "stickynote.active.mark" : "home.tab.archive",
                                              systemImage: note.isDone ? "arrow.clockwise" : "archivebox")
                                    }
                                    Button(role: .destructive, action: { viewModel.deleteNote(id: note.id) }) {
                                        Label("common.delete", systemImage: "trash")
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
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(themeManager.theme.color)
                                .clipShape(Circle())
                                .shadow(color: themeManager.theme.color.opacity(0.3), radius: 10, x: 0, y: 5)
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
        HIGEmptyStateView(
            icon: showingArchivedNotes ? "clock" : "note.text",
            title: getEmptyStateTitle(),
            message: getEmptyStateMessage()
        )
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
            Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                .font(.system(size: 20))
                .foregroundColor(themeManager.theme.color)
        }
    }
}

// MARK: - Note List Row (List View Mode)
struct NoteListRow: View {
    @EnvironmentObject var themeManager: ThemeManager
    let note: StickyNote
    var isSelecting: Bool = false
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: 0) {
            // Leading color swatch
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(note.colorValue)
                .frame(width: 5)
                .padding(.vertical, 14)
                .padding(.leading, 16)

            // Selection circle
            if isSelecting {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? themeManager.theme.color : .secondary)
                    .font(.title3)
                    .padding(.leading, 12)
                    .transition(.scale)
            }

            // Content
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(note.title)
                        .font(.body.weight(.semibold))
                        .lineLimit(1)
                        .foregroundColor(.primary)

                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    if hasAttachments {
                        Image(systemName: "paperclip")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    if note.priority != .none {
                        Circle()
                            .fill(priorityColor(note.priority))
                            .frame(width: 8, height: 8)
                    }

                    if note.isTimeBounded {
                        Text(formattedDate(note.startDate))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }

                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 16)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
    }

    private var hasAttachments: Bool {
        note.attachmentData != nil || note.audioURLString != nil || note.videoURLString != nil
    }

    private func priorityColor(_ priority: Priority) -> Color {
        switch priority {
        case .high:   return .red
        case .medium: return .orange
        case .low:    return .blue
        case .none:   return .clear
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
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
                .font(.system(size: 11, weight: .semibold))
            
            Text(LocalizedStringKey(title))
                .font(.subheadline.weight(.medium))
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(color.opacity(0.6))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(color.opacity(0.12))
        )
        .foregroundColor(color)
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
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(isSelected ? themeManager.theme.color : Color(.systemGray5))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
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
                Section {
                    Picker(selection: Binding(
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
                    } label: {
                        HStack(spacing: 14) {
                            HIGIcon(systemName: "tag.fill", color: .green)
                            Text("addnote.category")
                        }
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
                } header: {
                    Text("addnote.category")
                }
                
                Section {
                    Picker(selection: $viewModel.dateFilterOption) {
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
                    } label: {
                        HStack(spacing: 14) {
                            HIGIcon(systemName: "calendar", color: .blue)
                            Text("home.filters.date")
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                } header: {
                    Text("home.filters.date")
                }
                
                Section {
                    Toggle(isOn: $viewModel.showOnlyWithAttachments) {
                        HStack(spacing: 14) {
                            HIGIcon(systemName: "paperclip", color: .orange)
                            Text("home.filters.content.attachments")
                        }
                    }
                    Toggle(isOn: $viewModel.showOnlyWithReminders) {
                        HStack(spacing: 14) {
                            HIGIcon(systemName: "bell.fill", color: .red)
                            Text("home.filters.content.reminders")
                        }
                    }
                } header: {
                    Text("home.filters.content")
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

