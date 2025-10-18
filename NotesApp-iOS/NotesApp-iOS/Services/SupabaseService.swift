import Foundation
import Supabase

class SupabaseService {
    static let shared = SupabaseService()
    
    private let supabase: SupabaseClient
    
    private init() {
        // Load configuration from SupabaseConfig
        let supabaseURL = URL(string: SupabaseConfig.url)!
        let supabaseKey = SupabaseConfig.anonKey
        
        self.supabase = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
        
        print("📊 Supabase initialized")
        print("🔗 URL: \(SupabaseConfig.url)")
    }
    
    // MARK: - Notes CRUD Operations
    
    func fetchNotes(userId: String) async throws -> [Note] {
        print("📚 Fetching notes for user: \(userId)")
        
        let response: [Note] = try await supabase.database
            .from("notes")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        print("✅ Fetched \(response.count) notes")
        return response
    }
    
    func createNote(title: String, content: String, userId: String, attachments: [Attachment] = []) async throws -> Note {
        print("➕ Creating note: \(title)")
        
        let noteCreate = NoteCreate(
            title: title,
            content: content,
            userId: userId,
            isFavorite: false,
            tags: [],
            attachments: attachments
        )
        
        let response: Note = try await supabase.database
            .from("notes")
            .insert(noteCreate)
            .select()
            .single()
            .execute()
            .value
        
        print("✅ Note created with ID: \(response.id)")
        return response
    }
    
    func updateNote(id: Int, title: String, content: String, attachments: [Attachment]?) async throws -> Note {
        print("✏️ Updating note: \(id)")
        
        let noteUpdate = NoteUpdate(title: title, content: content, attachments: attachments)
        
        let response: Note = try await supabase.database
            .from("notes")
            .update(noteUpdate)
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
        
        print("✅ Note updated successfully")
        return response
    }
    
    func deleteNote(id: Int, userId: String) async throws {
        print("🗑️ Deleting note: \(id)")
        
        try await supabase.database
            .from("notes")
            .delete()
            .eq("id", value: id)
            .eq("user_id", value: userId)
            .execute()
        
        print("✅ Note deleted successfully")
    }
    
    // MARK: - User Profile
    
    func fetchUserProfile(userId: String) async throws -> UserProfile? {
        print("👤 Fetching user profile: \(userId)")
        
        do {
            let response: UserProfile = try await supabase.database
                .from("user_profiles")
                .select()
                .eq("user_id", value: userId)
                .single()
                .execute()
                .value
            
            print("✅ User profile fetched, isPremium: \(response.isPremium)")
            return response
        } catch {
            print("⚠️ User profile not found: \(error.localizedDescription)")
            return nil
        }
    }
    
    func createOrUpdateUserProfile(userId: String, email: String, name: String?) async throws {
        print("👤 Creating/updating user profile: \(userId)")
        
        // Check if profile exists
        let existingProfile = try? await fetchUserProfile(userId: userId)
        
        if existingProfile != nil {
            // Update existing profile
            let updateData: [String: Any] = [
                "email": email,
                "name": name ?? ""
            ]
            
            try await supabase.database
                .from("user_profiles")
                .update(updateData)
                .eq("user_id", value: userId)
                .execute()
            
            print("✅ User profile updated")
        } else {
            // Create new profile
            let profileData: [String: Any] = [
                "user_id": userId,
                "email": email,
                "name": name ?? "",
                "is_premium": false
            ]
            
            try await supabase.database
                .from("user_profiles")
                .insert(profileData)
                .execute()
            
            print("✅ User profile created")
        }
    }
    
    // MARK: - File Storage
    
    func uploadFile(data: Data, fileName: String, userId: String) async throws -> Attachment {
        print("📎 Uploading file: \(fileName)")
        
        let fileExtension = (fileName as NSString).pathExtension
        let uniqueFileName = "\(Date().timeIntervalSince1970)-\(UUID().uuidString).\(fileExtension)"
        let filePath = "notes/\(userId)/\(uniqueFileName)"
        
        let fileData = try await supabase.storage
            .from("note-attachments")
            .upload(
                path: filePath,
                file: data,
                options: FileOptions(contentType: mimeType(for: fileExtension))
            )
        
        print("✅ File uploaded: \(fileData.path)")
        
        return Attachment(
            name: fileName,
            path: fileData.path,
            size: data.count,
            type: mimeType(for: fileExtension),
            url: fileData.path
        )
    }
    
    func deleteFile(path: String) async throws {
        print("🗑️ Deleting file: \(path)")
        
        try await supabase.storage
            .from("note-attachments")
            .remove(paths: [path])
        
        print("✅ File deleted")
    }
    
    func downloadFile(path: String) async throws -> Data {
        print("⬇️ Downloading file: \(path)")
        
        let data = try await supabase.storage
            .from("note-attachments")
            .download(path: path)
        
        print("✅ File downloaded: \(data.count) bytes")
        return data
    }
    
    // MARK: - Helper Methods
    
    private func mimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "gif":
            return "image/gif"
        case "pdf":
            return "application/pdf"
        case "txt":
            return "text/plain"
        case "doc":
            return "application/msword"
        case "docx":
            return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        default:
            return "application/octet-stream"
        }
    }
}

