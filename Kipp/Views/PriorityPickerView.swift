//
//  PriorityPickerView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

struct PriorityPickerView: View {
    @Binding var selectedPriority: Priority

    var body: some View {
        Form {
            Section {
                ForEach(Priority.allCases) { priority in
                    Button {
                        selectedPriority = priority
                    } label: {
                        HStack(spacing: 14) {
                            // Circular colored icon with flag
                            Image(systemName: priority.flagIcon)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(priority.iconColor)
                                .frame(width: 40, height: 40)
                                .background(priority.iconColor.opacity(0.12))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(LocalizedStringKey(priority.rawValue))
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.primary)
                                Text(priority.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if selectedPriority == priority {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                }
            } header: {
                Text(String(localized: "priority.section.select"))
            }
        }
        .navigationTitle(String(localized: "priority.title"))
        .navigationBarTitleDisplayMode(.inline)
    }
}
