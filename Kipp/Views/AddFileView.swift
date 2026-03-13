//
//  AddFileView.swift
//  Kipp
//
//  Created by Shams Tabrej Alam on 13/02/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct AddFileView: View {
    @Binding var selectedFileURL: URL?

    enum FilePickerType: Identifiable {
        case document, archive, other
        var id: Self { self }
        
        var contentTypes: [UTType] {
            switch self {
            case .document: return [.pdf, .plainText, .rtf, .rtfd]
            case .archive: return [.archive, .zip, .gzip]
            case .other: return [.item]
            }
        }
    }

    @State private var activePicker: FilePickerType?

    var body: some View {
        Form {
            // MARK: File Type Section
            Section {
                Button {
                    activePicker = .document
                } label: {
                    AttachmentSourceRow(
                        icon: "doc.fill",
                        iconColor: .blue,
                        title: String(localized: "addfile.type.document"),
                        subtitle: String(localized: "addfile.type.document.subtitle")
                    )
                }

                Button {
                    activePicker = .archive
                } label: {
                    AttachmentSourceRow(
                        icon: "archivebox.fill",
                        iconColor: .orange,
                        title: String(localized: "addfile.type.archive"),
                        subtitle: String(localized: "addfile.type.archive.subtitle")
                    )
                }

                Button {
                    activePicker = .other
                } label: {
                    AttachmentSourceRow(
                        icon: "doc.fill",
                        iconColor: Color(.systemGray),
                        title: String(localized: "addfile.type.other"),
                        subtitle: String(localized: "addfile.type.other.subtitle")
                    )
                }
            } header: {
                Text(String(localized: "addfile.section.filetype"))
            }



            // MARK: Selected File Preview
            if let fileURL = selectedFileURL {
                Section {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: iconForFileExtension(fileURL.pathExtension))
                                .font(.system(size: 32))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(fileURL.lastPathComponent)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)

                                Text(fileURL.pathExtension.uppercased() + " " + String(localized: "addfile.selected.suffix"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)

                        Button(role: .destructive) {
                            selectedFileURL = nil
                        } label: {
                            Label(String(localized: "addfile.selected.remove"), systemImage: "trash")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                } header: {
                    Text(String(localized: "addfile.section.selected"))
                }
            }
        }
        .navigationTitle(String(localized: "addfile.title"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activePicker) { pickerType in
            GeneralDocumentPicker(
                contentTypes: pickerType.contentTypes,
                selectedURL: $selectedFileURL
            )
            .id(pickerType.id)
        }
    }

    // MARK: - File Icon Helper
    private func iconForFileExtension(_ ext: String) -> String {
        switch ext.lowercased() {
        case "pdf": return "doc.richtext.fill"
        case "doc", "docx": return "doc.text.fill"
        case "txt": return "doc.plaintext.fill"
        case "png", "jpg", "jpeg", "heic", "svg": return "photo.fill"
        case "zip", "rar", "7z", "gz": return "archivebox.fill"
        case "mp3", "m4a", "wav", "aiff": return "music.note"
        case "mp4", "mov", "avi": return "film"
        default: return "doc.fill"
        }
    }
}

// MARK: - General Document Picker

struct GeneralDocumentPicker: UIViewControllerRepresentable {
    let contentTypes: [UTType]
    @Binding var selectedURL: URL?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // UIDocumentPickerViewController doesn't allow changing contentTypes after creation.
        // But SwiftUI recreates the view when `contentTypes` changes if the ID changes, or we can just rely on the new instance being created on sheet presentation.
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: GeneralDocumentPicker

        init(_ parent: GeneralDocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            var didStart = false
            if url.startAccessingSecurityScopedResource() { didStart = true }
            defer { if didStart { url.stopAccessingSecurityScopedResource() } }

            let fileManager = FileManager.default
            let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documents.appendingPathComponent(url.lastPathComponent)

            do {
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try fileManager.removeItem(at: destinationURL)
                }
                try fileManager.copyItem(at: url, to: destinationURL)
                parent.selectedURL = destinationURL
            } catch {
                print("Failed to copy file: \(error)")
            }
        }
    }
}
