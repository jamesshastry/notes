//
//  NoteDetailView.swift
//  NotesIOSApp
//
//  Created on 2025-01-01.
//

import SwiftUI

struct NoteDetailView: View {
    @Environment(\.dismiss) var dismiss
    let note: Note
    let onUpdate: (Note) -> Void
    let onDelete: () -> Void
    
    @State private var showingEditView = false
    @State private var showingDeleteAlert = false
    @State private var selectedAttachment: Attachment?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    Text(note.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    // Metadata
                    HStack {
                        Label(note.createdAt.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                        
                        if note.createdAt != note.updatedAt {
                            Text("• Edited")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                    
                    Divider()
                    
                    // Content
                    Text(note.content)
                        .font(.body)
                    
                    // Attachments
                    if !note.attachments.isEmpty {
                        Divider()
                        
                        Text("Attachments")
                            .font(.headline)
                            .padding(.top, 10)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 15) {
                            ForEach(note.attachments) { attachment in
                                AttachmentCard(attachment: attachment)
                                    .onTapGesture {
                                        selectedAttachment = attachment
                                    }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showingEditView = true }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive, action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditView) {
            NoteEditView(note: note) { updatedNote in
                onUpdate(updatedNote)
                dismiss()
            }
        }
        .sheet(item: $selectedAttachment) { attachment in
            AttachmentViewer(attachment: attachment)
        }
        .alert("Delete Note", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
    }
}

struct AttachmentCard: View {
    let attachment: Attachment
    
    var body: some View {
        VStack {
            if attachment.type.hasPrefix("image/") {
                AsyncImage(url: URL(string: attachment.url)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: fileIcon(for: attachment.type))
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                    .frame(width: 100, height: 100)
            }
            
            Text(attachment.name)
                .font(.caption)
                .lineLimit(2)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
    }
    
    func fileIcon(for type: String) -> String {
        if type.hasPrefix("image/") { return "photo" }
        if type.hasPrefix("video/") { return "video" }
        if type == "application/pdf" { return "doc.text" }
        if type.contains("word") { return "doc.text" }
        if type.contains("zip") { return "archivebox" }
        return "doc"
    }
}

struct AttachmentViewer: View {
    @Environment(\.dismiss) var dismiss
    let attachment: Attachment
    @State private var isDownloading = false
    @State private var downloadedData: Data?
    
    var body: some View {
        NavigationView {
            Group {
                if isDownloading {
                    ProgressView("Loading...")
                } else if attachment.type.hasPrefix("image/") {
                    AsyncImage(url: URL(string: attachment.url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Text("Failed to load image")
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "doc")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text(attachment.name)
                            .font(.headline)
                        
                        Text(FirebaseStorageManager.shared.formatFileSize(attachment.size))
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button(action: downloadFile) {
                            Label("Download", systemImage: "arrow.down.circle")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func downloadFile() {
        isDownloading = true
        
        Task {
            do {
                let data = try await FirebaseStorageManager.shared.downloadFile(path: attachment.path)
                downloadedData = data
                
                // Save to Files app or share
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(attachment.name)
                try data.write(to: tempURL)
                
                await MainActor.run {
                    shareFile(url: tempURL)
                }
            } catch {
                print("❌ Download error: \(error)")
            }
            
            isDownloading = false
        }
    }
    
    func shareFile(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let viewController = windowScene.windows.first?.rootViewController {
            viewController.present(activityVC, animated: true)
        }
    }
}

#Preview {
    NoteDetailView(
        note: Note(
            id: 1,
            userId: "test",
            title: "Sample Note",
            content: "This is a sample note content.",
            attachments: []
        ),
        onUpdate: { _ in },
        onDelete: { }
    )
}

