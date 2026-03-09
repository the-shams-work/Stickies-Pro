//
//  HIGComponents.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI

// MARK: - HIG Settings-Style Icon

/// A colored rounded-rect icon matching the Apple Settings icon style.
struct HIGIcon: View {
    let systemName: String
    let color: Color
    var size: CGFloat = 29
    var iconSize: CGFloat = 15
    var cornerRadius: CGFloat = 6.5

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: iconSize, weight: .medium))
            .foregroundColor(.white)
            .frame(width: size, height: size)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - HIG Settings Row

/// A Form row with a leading colored icon, label, optional trailing detail, and optional chevron.
struct HIGSettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    var detail: String? = nil
    var detailColor: Color = .secondary
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            HIGIcon(systemName: icon, color: iconColor)

            Text(title)
                .foregroundColor(.primary)

            Spacer()

            if let detail {
                Text(detail)
                    .foregroundColor(detailColor)
            }

            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
    }
}

// MARK: - Onboarding Feature Row

/// A feature row for the welcome / onboarding screen following Apple HIG patterns.
struct OnboardingFeatureRow: View {
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(7)
                .frame(width: 36, height: 36)
                .background(iconColor, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Attachment Source Row

/// A row used in the attachment sub-screens with icon, title, and subtitle.
struct AttachmentSourceRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            HIGIcon(systemName: icon, color: iconColor)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Empty State View

/// A centred empty-state placeholder following HIG patterns.
struct HIGEmptyStateView: View {
    let icon: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .thin))
                .foregroundColor(.secondary)

            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundColor(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
