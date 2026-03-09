//
//  NoteColorPickerView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

// MARK: - Named Color Option

struct NoteColorOption: Identifiable, Equatable {
    let id: String
    let name: String
    let color: Color

    static let allOptions: [NoteColorOption] = [
        NoteColorOption(id: "none", name: String(localized: "color.none"), color: .clear),
        NoteColorOption(id: "default", name: String(localized: "color.default"), color: .blue),
        NoteColorOption(id: "rose", name: String(localized: "color.rose"), color: Color(red: 0.91, green: 0.30, blue: 0.40)),
        NoteColorOption(id: "orange", name: String(localized: "color.orange"), color: .orange),
        NoteColorOption(id: "amber", name: String(localized: "color.amber"), color: Color(red: 0.93, green: 0.70, blue: 0.13)),
        NoteColorOption(id: "emerald", name: String(localized: "color.emerald"), color: Color(red: 0.20, green: 0.71, blue: 0.47)),
        NoteColorOption(id: "teal", name: String(localized: "color.teal"), color: .teal),
        NoteColorOption(id: "cyan", name: String(localized: "color.cyan"), color: .cyan),
        NoteColorOption(id: "violet", name: String(localized: "color.violet"), color: Color(red: 0.48, green: 0.36, blue: 0.89)),
        NoteColorOption(id: "fuchsia", name: String(localized: "color.fuchsia"), color: Color(red: 0.82, green: 0.22, blue: 0.74)),
        NoteColorOption(id: "pink", name: String(localized: "color.pink"), color: .pink),
        NoteColorOption(id: "slate", name: String(localized: "color.slate"), color: Color(red: 0.44, green: 0.50, blue: 0.56)),
        NoteColorOption(id: "stone", name: String(localized: "color.stone"), color: Color(red: 0.47, green: 0.44, blue: 0.40)),
    ]

    static func == (lhs: NoteColorOption, rhs: NoteColorOption) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Note Color Picker View

struct NoteColorPickerView: View {
    @Binding var selectedColor: Color
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private var selectedOption: NoteColorOption? {
        NoteColorOption.allOptions.first { colorMatches($0.color, selectedColor) }
    }

    var body: some View {
        VStack(spacing: 0) {
            Form {
                // MARK: Preview Card
                Section {
                    NotePreviewCard(color: selectedColor)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }

                // MARK: Color Grid
                Section {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(NoteColorOption.allOptions) { option in
                            ColorCircleButton(
                                option: option,
                                isSelected: colorMatches(option.color, selectedColor),
                                action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedColor = option.color
                                    }
                                }
                            )
                        }
                    }
                    .padding(.vertical, 12)
                } header: {
                    Text(String(localized: "notecolor.section.choose"))
                }
            }
        }
        .navigationTitle(String(localized: "notecolor.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Color Matching Helper
    private func colorMatches(_ a: Color, _ b: Color) -> Bool {
        let uiA = UIColor(a)
        let uiB = UIColor(b)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        uiA.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        uiB.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        // Both clear/transparent
        if a1 < 0.01 && a2 < 0.01 { return true }
        let threshold: CGFloat = 0.02
        return abs(r1 - r2) < threshold && abs(g1 - g2) < threshold && abs(b1 - b2) < threshold && abs(a1 - a2) < threshold
    }
}

// MARK: - Color Circle Button

private struct ColorCircleButton: View {
    let option: NoteColorOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Outer ring when selected
                    if isSelected {
                        Circle()
                            .stroke(displayColor, lineWidth: 2.5)
                            .frame(width: 58, height: 58)
                    }

                    // Color circle
                    Circle()
                        .fill(displayColor)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(
                                    option.id == "none" ? Color(.separator) : Color.clear,
                                    lineWidth: option.id == "none" ? 1 : 0
                                )
                        )

                    // Diagonal line for "None"
                    if option.id == "none" && !isSelected {
                        Rectangle()
                            .fill(Color(.separator))
                            .frame(width: 1.5, height: 38)
                            .rotationEffect(.degrees(45))
                    }

                    // Checkmark
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(option.id == "none" ? .blue : .white)
                    }
                }
                .frame(width: 60, height: 60)

                Text(option.name)
                    .font(.caption2.weight(isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }

    private var displayColor: Color {
        if option.id == "none" { return Color(.systemBackground) }
        return option.color
    }
}

// MARK: - Note Preview Card

private struct NotePreviewCard: View {
    let color: Color

    private var isNone: Bool {
        let uiColor = UIColor(color)
        var alpha: CGFloat = 0
        uiColor.getRed(nil, green: nil, blue: nil, alpha: &alpha)
        return alpha < 0.01
    }

    private var isWhite: Bool { color.isWhite }

    private var previewBackground: Color {
        if isNone { return Color(.systemGray6) }
        if isWhite { return Color(.systemGray5) }
        return color.opacity(0.15)
    }

    private var accentColor: Color {
        if isNone { return Color(.systemGray3) }
        return color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Accent bar
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(accentColor)
                .frame(width: 48, height: 6)

            // Simulated title
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(accentColor.opacity(0.5))
                .frame(width: 200, height: 12)

            // Simulated subtitle
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(accentColor.opacity(0.35))
                .frame(width: 150, height: 10)

            // Simulated body lines
            ForEach(0..<3, id: \.self) { i in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color(.systemGray3).opacity(0.6))
                    .frame(width: CGFloat([280, 240, 200][i]), height: 8)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(previewBackground)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
    }
}
