//
//  BackgroundStylePickerView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

struct BackgroundStylePickerView: View {
    @Binding var selectedStyle: NoteBackgroundStyle

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 2)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // MARK: - Preview
                previewCard
                    .padding(.horizontal)

                // MARK: - Style Grid
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "backgroundstyle.section.style"))
                        .font(.footnote.weight(.medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(NoteBackgroundStyle.allCases) { style in
                            StyleThumbnailCard(
                                style: style,
                                isSelected: selectedStyle == style
                            )
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedStyle = style
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(String(localized: "backgroundstyle.title"))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Preview Card

    @ViewBuilder
    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(String(localized: "backgroundstyle.preview"))
                .font(.footnote.weight(.medium))
                .foregroundColor(.secondary)

            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(selectedStyle == .none ? Color(.secondarySystemGroupedBackground) : selectedStyle.backgroundColor)
                    .frame(height: 140)

                if selectedStyle != .none {
                    BackgroundPatternOverlay(style: selectedStyle)
                        .frame(height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                // Simulated note content
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.primary.opacity(0.45))
                        .frame(width: 100, height: 10)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.primary.opacity(0.25))
                        .frame(width: 180, height: 8)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.primary.opacity(0.25))
                        .frame(width: 140, height: 8)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.primary.opacity(0.25))
                        .frame(width: 160, height: 8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(.separator).opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - Style Thumbnail Card

private struct StyleThumbnailCard: View {
    let style: NoteBackgroundStyle
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(style == .none ? Color(.tertiarySystemGroupedBackground) : style.backgroundColor)

                    if style != .none {
                        BackgroundPatternOverlay(style: style, isThumb: true)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }

                    // Mini text lines
                    VStack(alignment: .leading, spacing: 4) {
                        if style == .none {
                            Image(systemName: "rectangle.slash")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        } else {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(.label).opacity(0.4))
                                .frame(width: 36, height: 5)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(.label).opacity(0.25))
                                .frame(width: 50, height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color(.label).opacity(0.25))
                                .frame(width: 42, height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: style == .none ? .center : .leading)
                    .padding(10)
                }
                .frame(height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(isSelected ? Color.accentColor : Color(.separator).opacity(0.3),
                                lineWidth: isSelected ? 2.5 : 1)
                )

                // Checkmark badge
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.white, Color.accentColor)
                        .offset(x: 6, y: -6)
                }
            }

            Text(LocalizedStringKey(style.rawValue))
                .font(.caption2)
                .foregroundColor(isSelected ? .accentColor : .secondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Background Pattern Overlay

struct BackgroundPatternOverlay: View {
    let style: NoteBackgroundStyle
    var isThumb: Bool = false

    var body: some View {
        Canvas { context, canvasSize in
            let spacing: CGFloat = isThumb ? 12 : 22
            let color = style.overlayColor

            switch style {
            case .lined:
                drawHorizontalLines(context: context, size: canvasSize, spacing: spacing, color: color)

            case .grid:
                drawHorizontalLines(context: context, size: canvasSize, spacing: spacing, color: color)
                drawVerticalLines(context: context, size: canvasSize, spacing: spacing, color: color)

            case .dotted:
                let dotRadius: CGFloat = isThumb ? 1.2 : 1.5
                drawDots(context: context, size: canvasSize, spacing: spacing, radius: dotRadius, color: color)

            case .ruled:
                drawHorizontalLines(context: context, size: canvasSize, spacing: spacing, color: color)
                let marginX: CGFloat = isThumb ? 16 : 36
                var marginPath = Path()
                marginPath.move(to: CGPoint(x: marginX, y: 0))
                marginPath.addLine(to: CGPoint(x: marginX, y: canvasSize.height))
                context.stroke(marginPath, with: .color(Color.red.opacity(0.35)), lineWidth: isThumb ? 0.5 : 1)

            case .dashed:
                let dashLen: CGFloat = isThumb ? 4 : 8
                let gapLen: CGFloat = isThumb ? 3 : 5
                var y: CGFloat = spacing
                while y < canvasSize.height {
                    var x: CGFloat = 0.0
                    while x < canvasSize.width {
                        var path = Path()
                        path.move(to: CGPoint(x: x, y: y))
                        path.addLine(to: CGPoint(x: min(x + dashLen, canvasSize.width), y: y))
                        context.stroke(path, with: .color(color), lineWidth: 0.5)
                        x += dashLen + gapLen
                    }
                    y += spacing
                }

            case .crosshatch:
                drawDiagonalLines(context: context, size: canvasSize, spacing: isThumb ? 10 : 18, color: color, direction: .both)

            case .columns:
                drawVerticalLines(context: context, size: canvasSize, spacing: spacing, color: color)

            case .checkerboard:
                let cell: CGFloat = isThumb ? 8 : 16
                var y: CGFloat = 0; var row = 0
                while y < canvasSize.height {
                    var x: CGFloat = 0; var col = 0
                    while x < canvasSize.width {
                        if (row + col) % 2 == 0 {
                            context.fill(Path(CGRect(x: x, y: y, width: cell, height: cell)), with: .color(color))
                        }
                        x += cell; col += 1
                    }
                    y += cell; row += 1
                }

            case .diagonal:
                drawDiagonalLines(context: context, size: canvasSize, spacing: isThumb ? 10 : 18, color: color, direction: .forward)

            case .diamond:
                // 45-degree rotated grid → diamond shapes
                let s: CGFloat = isThumb ? 12 : 22
                drawDiagonalLines(context: context, size: canvasSize, spacing: s, color: color, direction: .both)

            case .honeycomb:
                let r: CGFloat = isThumb ? 8 : 16 // hex radius
                let w = r * 2
                let h = r * sqrt(3)
                var row = 0
                var y: CGFloat = 0
                while y < canvasSize.height + h {
                    let offsetX: CGFloat = (row % 2 == 0) ? 0 : r
                    var x: CGFloat = offsetX
                    while x < canvasSize.width + w {
                        drawHexagon(context: context, center: CGPoint(x: x, y: y), radius: r, color: color)
                        x += w
                    }
                    y += h * 0.75
                    row += 1
                }

            case .zigzag:
                let amp: CGFloat = isThumb ? 4 : 8
                let period: CGFloat = isThumb ? 12 : 24
                var y: CGFloat = spacing
                while y < canvasSize.height {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    var x: CGFloat = 0
                    var up = true
                    while x < canvasSize.width {
                        let nextX = min(x + period / 2, canvasSize.width)
                        let nextY = up ? y - amp : y + amp
                        path.addLine(to: CGPoint(x: nextX, y: nextY))
                        x = nextX
                        up.toggle()
                    }
                    context.stroke(path, with: .color(color), lineWidth: 0.5)
                    y += spacing
                }

            case .waves:
                let amp: CGFloat = isThumb ? 3 : 6
                let waveLen: CGFloat = isThumb ? 16 : 32
                var y: CGFloat = spacing
                while y < canvasSize.height {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    var x: CGFloat = 0
                    while x < canvasSize.width {
                        let cp1 = CGPoint(x: x + waveLen / 4, y: y - amp)
                        let cp2 = CGPoint(x: x + waveLen / 4 * 3, y: y + amp)
                        let end = CGPoint(x: x + waveLen, y: y)
                        path.addCurve(to: end, control1: cp1, control2: cp2)
                        x += waveLen
                    }
                    context.stroke(path, with: .color(color), lineWidth: 0.5)
                    y += spacing
                }

            case .plusGrid:
                let arm: CGFloat = isThumb ? 3 : 5
                var y: CGFloat = spacing
                while y < canvasSize.height {
                    var x: CGFloat = spacing
                    while x < canvasSize.width {
                        // Horizontal arm
                        var h = Path()
                        h.move(to: CGPoint(x: x - arm, y: y))
                        h.addLine(to: CGPoint(x: x + arm, y: y))
                        context.stroke(h, with: .color(color), lineWidth: 0.5)
                        // Vertical arm
                        var v = Path()
                        v.move(to: CGPoint(x: x, y: y - arm))
                        v.addLine(to: CGPoint(x: x, y: y + arm))
                        context.stroke(v, with: .color(color), lineWidth: 0.5)
                        x += spacing
                    }
                    y += spacing
                }

            case .circles:
                let r: CGFloat = isThumb ? 4 : 8
                var y: CGFloat = spacing
                while y < canvasSize.height {
                    var x: CGFloat = spacing
                    while x < canvasSize.width {
                        let rect = CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)
                        context.stroke(Path(ellipseIn: rect), with: .color(color), lineWidth: 0.5)
                        x += spacing * 1.5
                    }
                    y += spacing * 1.5
                }

            case .herringbone:
                let segLen: CGFloat = isThumb ? 8 : 16
                let rowH: CGFloat = isThumb ? 8 : 16
                var y: CGFloat = 0
                var row = 0
                while y < canvasSize.height {
                    let offsetX: CGFloat = (row % 2 == 0) ? 0 : segLen
                    var x: CGFloat = offsetX
                    while x < canvasSize.width + segLen {
                        // Forward slash
                        var p1 = Path()
                        p1.move(to: CGPoint(x: x, y: y + rowH))
                        p1.addLine(to: CGPoint(x: x + segLen / 2, y: y))
                        context.stroke(p1, with: .color(color), lineWidth: 0.5)
                        // Back slash
                        var p2 = Path()
                        p2.move(to: CGPoint(x: x + segLen / 2, y: y))
                        p2.addLine(to: CGPoint(x: x + segLen, y: y + rowH))
                        context.stroke(p2, with: .color(color), lineWidth: 0.5)
                        x += segLen * 2
                    }
                    y += rowH
                    row += 1
                }

            case .brickwork:
                let brickW: CGFloat = isThumb ? 16 : 32
                let brickH: CGFloat = isThumb ? 8 : 14
                var y: CGFloat = 0
                var row = 0
                while y < canvasSize.height {
                    // Horizontal line
                    var hLine = Path()
                    hLine.move(to: CGPoint(x: 0, y: y))
                    hLine.addLine(to: CGPoint(x: canvasSize.width, y: y))
                    context.stroke(hLine, with: .color(color), lineWidth: 0.5)
                    // Vertical joints – offset every other row
                    let offsetX: CGFloat = (row % 2 == 0) ? 0 : brickW / 2
                    var x = offsetX
                    while x < canvasSize.width {
                        var vLine = Path()
                        vLine.move(to: CGPoint(x: x, y: y))
                        vLine.addLine(to: CGPoint(x: x, y: y + brickH))
                        context.stroke(vLine, with: .color(color), lineWidth: 0.5)
                        x += brickW
                    }
                    y += brickH
                    row += 1
                }

            case .wideRuled:
                let wideSpacing: CGFloat = isThumb ? 18 : 34
                drawHorizontalLines(context: context, size: canvasSize, spacing: wideSpacing, color: color)
                let marginX: CGFloat = isThumb ? 16 : 36
                var marginPath = Path()
                marginPath.move(to: CGPoint(x: marginX, y: 0))
                marginPath.addLine(to: CGPoint(x: marginX, y: canvasSize.height))
                context.stroke(marginPath, with: .color(Color.red.opacity(0.35)), lineWidth: isThumb ? 0.5 : 1)

            case .thinGrid:
                let tight: CGFloat = isThumb ? 6 : 12
                drawHorizontalLines(context: context, size: canvasSize, spacing: tight, color: color)
                drawVerticalLines(context: context, size: canvasSize, spacing: tight, color: color)

            case .none:
                break
            }
        }
    }

    // MARK: - Drawing Helpers

    private enum DiagonalDirection { case forward, backward, both }

    private func drawHorizontalLines(context: GraphicsContext, size: CGSize, spacing: CGFloat, color: Color) {
        var y: CGFloat = spacing
        while y < size.height {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: size.width, y: y))
            context.stroke(path, with: .color(color), lineWidth: 0.5)
            y += spacing
        }
    }

    private func drawVerticalLines(context: GraphicsContext, size: CGSize, spacing: CGFloat, color: Color) {
        var x: CGFloat = spacing
        while x < size.width {
            var path = Path()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: size.height))
            context.stroke(path, with: .color(color), lineWidth: 0.5)
            x += spacing
        }
    }

    private func drawDiagonalLines(context: GraphicsContext, size: CGSize, spacing: CGFloat, color: Color, direction: DiagonalDirection) {
        let total = size.width + size.height
        if direction == .forward || direction == .both {
            var offset: CGFloat = -size.height
            while offset < total {
                var path = Path()
                path.move(to: CGPoint(x: offset, y: 0))
                path.addLine(to: CGPoint(x: offset + size.height, y: size.height))
                context.stroke(path, with: .color(color), lineWidth: 0.5)
                offset += spacing
            }
        }
        if direction == .backward || direction == .both {
            var offset: CGFloat = -size.height
            while offset < total {
                var path = Path()
                path.move(to: CGPoint(x: offset + size.height, y: 0))
                path.addLine(to: CGPoint(x: offset, y: size.height))
                context.stroke(path, with: .color(color), lineWidth: 0.5)
                offset += spacing
            }
        }
    }

    private func drawDots(context: GraphicsContext, size: CGSize, spacing: CGFloat, radius: CGFloat, color: Color) {
        var y: CGFloat = spacing
        while y < size.height {
            var x: CGFloat = spacing
            while x < size.width {
                let rect = CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)
                context.fill(Path(ellipseIn: rect), with: .color(color))
                x += spacing
            }
            y += spacing
        }
    }

    private func drawHexagon(context: GraphicsContext, center: CGPoint, radius: CGFloat, color: Color) {
        var path = Path()
        for i in 0..<6 {
            let angle = CGFloat(i) * .pi / 3 - .pi / 6
            let point = CGPoint(x: center.x + radius * cos(angle), y: center.y + radius * sin(angle))
            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        context.stroke(path, with: .color(color), lineWidth: 0.5)
    }
}
