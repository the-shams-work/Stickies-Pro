//
//  CategoryPickerView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: NoteCategory?

    @State private var showCustomCategoryAlert = false
    @State private var customCategoryInput = ""

    var body: some View {
        Form {
            Section {
                ForEach(NoteCategory.allCases, id: \.id) { category in
                    Button {
                        selectedCategory = category
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: category.systemImage)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(category.iconColor)
                                .frame(width: 40, height: 40)
                                .background(category.iconColor.opacity(0.12))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(category.rawValue)
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.primary)
                                Text(category.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if selectedCategory == category {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
            } header: {
                Text("SELECT CATEGORY")
            }

            // Custom category
            Section {
                Button {
                    customCategoryInput = ""
                    showCustomCategoryAlert = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(width: 40, height: 40)
                            .background(Color.blue.opacity(0.12))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Custom Category")
                                .font(.body.weight(.medium))
                                .foregroundColor(.primary)
                            Text("Create your own category")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        if let selected = selectedCategory, case .custom = selected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                }
            } header: {
                Text("CUSTOM")
            }
        }
        .navigationTitle("Category")
        .navigationBarTitleDisplayMode(.inline)
        .alert("home.filters.category.custom.alert", isPresented: $showCustomCategoryAlert, actions: {
            TextField("home.filters.category.custom.placeholder", text: $customCategoryInput)
            Button("common.ok") {
                let trimmed = customCategoryInput.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    selectedCategory = .custom(trimmed)
                }
            }
            Button("common.cancel", role: .cancel) { }
        }, message: {
            Text("home.filters.category.custom.message")
        })
    }
}
