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

    @State private var showDocumentPicker = false
    @State private var pickerContentTypes: [UTType] = []

    var body: some View {
        Form {
            // MARK: File Type Section
            Section {
                Button {
                    pickerContentTypes = [.pdf, .plainText, .rtf, .rtfd]
                    showDocumentPicker = true
                } label: {
                    AttachmentSourceRow(
                        icon: "doc.fill",
                        iconColor: .blue,
                        title: "Document",
                        subtitle: "PDF, DOCX, TXT"
                    )
                }

                Button {
                    pickerContentTypes = [.image, .png, .jpeg, .svg, .heic]
                    showDocumentPicker = true
                } label: {
                    AttachmentSourceRow(
                        icon: "photo.fill",
                        iconColor: .green,
                        title: "Image",
                        subtitle: "PNG, JPG, SVG"
                    )
                }

                Button {
                    pickerContentTypes = [.archive, .zip, .gzip]
                    showDocumentPicker = true
                } label: {
                    AttachmentSourceRow(
                        icon: "archivebox.fill",
                        iconColor: .orange,
                        title: "Archive",
                        subtitle: "ZIP, RAR, 7Z"
                    )
                }

                Button {
                    pickerContentTypes = [.item]
                    showDocumentPicker = true
                } label: {
                    AttachmentSourceRow(
                        icon: "doc.fill",
                        iconColor: Color(.systemGray),
                        title: "Other",
                        subtitle: "Any file type"
                    )
                }
            } header: {
                Text("FILE TYPE")
            }

            // MARK: Drop Zone
            Section {
                Button {
                    pickerContentTypes = [.item]
                    showDocumentPicker = true
                } label: {
                    VStack(spacing: 10) {
                        Image(systemName: "square.and.arrow.down")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.blue)

                        Text("Browse to attach")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.primary)

                        Text("Supports all common file types")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 28)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [8, 5]))
                            .foregroundColor(Color(.tertiaryLabel))
                    )
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
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

                                Text(fileURL.pathExtension.uppercased() + " file")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)

                        Button(role: .destructive) {
                            selectedFileURL = nil
                        } label: {
                            Label("Remove File", systemImage: "trash")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity)
                } header: {
                    Text("SELECTED FILE")
                }
            }
        }
        .navigationTitle("Add File")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showDocumentPicker) {
            GeneralDocumentPicker(
                contentTypes: pickerContentTypes,
                selectedURL: $selectedFileURL
            )
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

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

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
