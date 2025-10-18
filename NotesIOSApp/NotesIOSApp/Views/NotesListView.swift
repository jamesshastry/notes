//
//  NotesListView.swift
//  NotesIOSApp
//
//  Created on 2025-01-01.
//

import SwiftUI

struct NotesListView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var viewModel = NotesListViewModel()
    @State private var showingAddNote = false
    @State private var searchText = ""
    @State private var selectedNote: Note?
    @State private var showingDetail = false
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return viewModel.notes
        } else {
            return viewModel.notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.notes.isEmpty {
                    ProgressView("Loading notes...")
                } else if filteredNotes.isEmpty {
                    emptyStateView
                } else {
                    notesList
                }
            }
            .navigationTitle("My Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    userProfileButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search notes")
            .refreshable {
                await viewModel.loadNotes()
            }
        }
        .sheet(isPresented: $showingAddNote) {
            NoteEditView(note: nil, onSave: { note in
                Task {
                    await viewModel.createNote(note)
                }
            })
        }
        .sheet(item: $selectedNote) { note in
            NoteDetailView(note: note, onUpdate: { updatedNote in
                Task {
                    await viewModel.updateNote(updatedNote)
                }
            }, onDelete: {
                Task {
                    await viewModel.deleteNote(note)
                }
            })
        }
        .task {
            await viewModel.loadNotes()
            await viewModel.loadPremiumStatus()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    private var notesList: some View {
        ScrollView {
            LazyVStack(spacing: 15) {
                ForEach(filteredNotes) { note in
                    NoteCard(note: note)
                        .onTapGesture {
                            selectedNote = note
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteNote(note)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Notes Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap + to create your first note")
                .font(.body)
                .foregroundColor(.gray)
            
            Button(action: { showingAddNote = true }) {
                Text("Create Note")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
    
    private var userProfileButton: some View {
        Menu {
            if let user = authManager.currentUser {
                Text(user.email ?? "No email")
                    .font(.caption)
            }
            
            if viewModel.isPremium {
                Label("Premium User", systemImage: "star.fill")
                    .foregroundColor(.yellow)
            } else {
                Label("Free User", systemImage: "person")
            }
            
            Divider()
            
            Button(role: .destructive, action: {
                Task {
                    try? await authManager.signOut()
                }
            }) {
                Label("Sign Out", systemImage: "arrow.right.square")
            }
        } label: {
            HStack(spacing: 8) {
                if viewModel.isPremium {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
                
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
        }
    }
}

struct NoteCard: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.headline)
                .lineLimit(1)
            
            Text(note.content)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(3)
            
            HStack {
                Text(note.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if !note.attachments.isEmpty {
                    Label("\(note.attachments.count)", systemImage: "paperclip")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

@MainActor
class NotesListViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPremium = false
    
    private let supabaseManager = SupabaseManager.shared
    
    func loadNotes() async {
        guard let userId = AuthenticationManager.shared.currentUser?.uid else { return }
        
        isLoading = true
        
        do {
            notes = try await supabaseManager.fetchNotes(userId: userId)
            print("✅ Loaded \(notes.count) notes")
        } catch {
            errorMessage = "Failed to load notes: \(error.localizedDescription)"
            print("❌ Error loading notes: \(error)")
        }
        
        isLoading = false
    }
    
    func loadPremiumStatus() async {
        guard let userId = AuthenticationManager.shared.currentUser?.uid else { return }
        
        do {
            isPremium = try await supabaseManager.checkPremiumStatus(userId: userId)
            print("✅ Premium status: \(isPremium)")
        } catch {
            print("❌ Error loading premium status: \(error)")
            isPremium = false
        }
    }
    
    func createNote(_ note: Note) async {
        guard let userId = AuthenticationManager.shared.currentUser?.uid else { return }
        
        var newNote = note
        newNote.userId = userId
        
        do {
            let createdNote = try await supabaseManager.createNote(note: newNote)
            notes.insert(createdNote, at: 0)
            print("✅ Note created")
        } catch {
            errorMessage = "Failed to create note: \(error.localizedDescription)"
            print("❌ Error creating note: \(error)")
        }
    }
    
    func updateNote(_ note: Note) async {
        guard let noteId = note.id else { return }
        
        do {
            let updatedNote = try await supabaseManager.updateNote(noteId: noteId, note: note)
            if let index = notes.firstIndex(where: { $0.id == noteId }) {
                notes[index] = updatedNote
            }
            print("✅ Note updated")
        } catch {
            errorMessage = "Failed to update note: \(error.localizedDescription)"
            print("❌ Error updating note: \(error)")
        }
    }
    
    func deleteNote(_ note: Note) async {
        guard let noteId = note.id,
              let userId = AuthenticationManager.shared.currentUser?.uid else { return }
        
        do {
            // Delete attachments first
            for attachment in note.attachments {
                try? await FirebaseStorageManager.shared.deleteFile(path: attachment.path)
            }
            
            try await supabaseManager.deleteNote(noteId: noteId, userId: userId)
            notes.removeAll { $0.id == noteId }
            print("✅ Note deleted")
        } catch {
            errorMessage = "Failed to delete note: \(error.localizedDescription)"
            print("❌ Error deleting note: \(error)")
        }
    }
}

#Preview {
    NotesListView()
        .environmentObject(AuthenticationManager.shared)
}

