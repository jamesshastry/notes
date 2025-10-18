//
//  NoteEditView.swift
//  NotesIOSApp
//
//  Created on 2025-01-01.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct NoteEditView: View {
    @Environment(\.dismiss) var dismiss
    
    let note: Note?
    let onSave: (Note) -> Void
    
    @State private var title = ""
    @State private var content = ""
    @State private var attachments: [Attachment] = []
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var showingFilePicker = false
    @State private var showingPhotoPicker = false
    @State private var isUploading = false
    @State private var uploadProgress = 0.0
    
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Note Details")) {
                    TextField("Title", text: $title)
                        .font(.headline)
                    
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
                
                Section(header: Text("Attachments")) {
                    if !attachments.isEmpty {
                        ForEach(attachments) { attachment in
                            HStack {
                                Image(systemName: fileIcon(for: attachment.type))
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading) {
                                    Text(attachment.name)
                                        .font(.subheadline)
                                    Text(FirebaseStorageManager.shared.formatFileSize(attachment.size))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(role: .destructive) {
                                    removeAttachment(attachment)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    
                    Button(action: { showingPhotoPicker = true }) {
                        Label("Add Photos", systemImage: "photo")
                    }
                    
                    Button(action: { showingFilePicker = true }) {
                        Label("Add Files", systemImage: "doc")
                    }
                }
                
                if isUploading {
                    Section {
                        HStack {
                            ProgressView(value: uploadProgress)
                            Text("\(Int(uploadProgress * 100))%")
                                .font(.caption)
                        }
                    }
                }
            }
            .navigationTitle(note == nil ? "New Note" : "Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(!isValid || isUploading)
                }
            }
        }
        .photosPicker(isPresented: $showingPhotoPicker, selection: $selectedPhotos, matching: .images)
        .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [.pdf, .text, .plainText, .data], allowsMultipleSelection: true) { result in
            handleFileSelection(result)
        }
        .onChange(of: selectedPhotos) { _, newItems in
            Task {
                await uploadPhotos(newItems)
            }
        }
        .onAppear {
            if let note = note {
                title = note.title
                content = note.content
                attachments = note.attachments
            }
        }
    }
    
    private func saveNote() {
        guard let userId = AuthenticationManager.shared.currentUser?.uid else { return }
        
        var savedNote = note ?? Note(
            userId: userId,
            title: "",
            content: ""
        )
        
        savedNote.title = title
        savedNote.content = content
        savedNote.attachments = attachments
        savedNote.updatedAt = Date()
        
        onSave(savedNote)
        dismiss()
    }
    
    private func uploadPhotos(_ items: [PhotosPickerItem]) async {
        guard let userId = AuthenticationManager.shared.currentUser?.uid else { return }
        
        isUploading = true
        uploadProgress = 0.0
        
        for (index, item) in items.enumerated() {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    
                    let fileName = "photo_\(Date().timeIntervalSince1970).jpg"
                    let attachment = try await FirebaseStorageManager.shared.uploadImage(
                        image: image,
                        userId: userId,
                        fileName: fileName
                    )
                    
                    await MainActor.run {
                        attachments.append(attachment)
                        uploadProgress = Double(index + 1) / Double(items.count)
                    }
                }
            } catch {
                print("❌ Error uploading photo: \(error)")
            }
        }
        
        isUploading = false
        selectedPhotos = []
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        guard let userId = AuthenticationManager.shared.currentUser?.uid else { return }
        
        switch result {
        case .success(let urls):
            isUploading = true
            uploadProgress = 0.0
            
            Task {
                for (index, url) in urls.enumerated() {
                    do {
                        // Access security-scoped resource
                        guard url.startAccessingSecurityScopedResource() else {
                            continue
                        }
                        defer { url.stopAccessingSecurityScopedResource() }
                        
                        let data = try Data(contentsOf: url)
                        let fileName = url.lastPathComponent
                        let contentType = FirebaseStorageManager.shared.getContentType(for: fileName)
                        
                        let attachment = try await FirebaseStorageManager.shared.uploadFile(
                            data: data,
                            userId: userId,
                            fileName: fileName,
                            contentType: contentType
                        )
                        
                        await MainActor.run {
                            attachments.append(attachment)
                            uploadProgress = Double(index + 1) / Double(urls.count)
                        }
                    } catch {
                        print("❌ Error uploading file: \(error)")
                    }
                }
                
                await MainActor.run {
                    isUploading = false
                }
            }
            
        case .failure(let error):
            print("❌ File selection error: \(error)")
            isUploading = false
        }
    }
    
    private func removeAttachment(_ attachment: Attachment) {
        attachments.removeAll { $0.id == attachment.id }
        
        // Delete from Firebase Storage
        Task {
            do {
                try await FirebaseStorageManager.shared.deleteFile(path: attachment.path)
                print("✅ Attachment deleted from storage")
            } catch {
                print("❌ Error deleting attachment: \(error)")
            }
        }
    }
    
    private func fileIcon(for type: String) -> String {
        if type.hasPrefix("image/") { return "photo" }
        if type.hasPrefix("video/") { return "video" }
        if type == "application/pdf" { return "doc.text" }
        if type.contains("word") { return "doc.text" }
        if type.contains("zip") { return "archivebox" }
        return "doc"
    }
}

#Preview {
    NoteEditView(note: nil) { _ in }
}

