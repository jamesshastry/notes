//
//  SupabaseManager.swift
//  NotesIOSApp
//
//  Created on 2025-01-01.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    private var client: SupabaseClient
    
    // TODO: Replace these with your actual Supabase credentials
    private let supabaseURL = "YOUR_SUPABASE_URL"
    private let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"
    
    private init() {
        guard let url = URL(string: supabaseURL) else {
            fatalError("Invalid Supabase URL")
        }
        
        client = SupabaseClient(supabaseURL: url, supabaseKey: supabaseAnonKey)
    }
    
    // MARK: - User Profile Operations
    
    func fetchUserProfile(userId: String) async throws -> UserProfile? {
        let response: [UserProfile] = try await client
            .from("user_profiles")
            .select()
            .eq("user_id", value: userId)
            .execute()
            .value
        
        return response.first
    }
    
    func createUserProfile(profile: UserProfile) async throws {
        try await client
            .from("user_profiles")
            .insert(profile)
            .execute()
    }
    
    func updateUserProfile(userId: String, profile: UserProfile) async throws {
        try await client
            .from("user_profiles")
            .update(profile)
            .eq("user_id", value: userId)
            .execute()
    }
    
    // MARK: - Subscription Status Operations
    
    func fetchSubscriptionStatus(userId: String) async throws -> SubscriptionStatus? {
        let response: [SubscriptionStatus] = try await client
            .from("subscription_status")
            .select()
            .eq("user_id", value: userId)
            .order("updated_at", ascending: false)
            .limit(1)
            .execute()
            .value
        
        return response.first
    }
    
    func checkPremiumStatus(userId: String) async throws -> Bool {
        // First check subscription_status table
        if let subscription = try await fetchSubscriptionStatus(userId: userId) {
            return subscription.status
        }
        
        // Fall back to user_profiles table
        if let profile = try await fetchUserProfile(userId: userId) {
            return profile.isPremium
        }
        
        return false
    }
    
    // MARK: - Notes CRUD Operations
    
    func fetchNotes(userId: String) async throws -> [Note] {
        let response: [Note] = try await client
            .from("notes")
            .select()
            .eq("user_id", value: userId)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return response
    }
    
    func createNote(note: Note) async throws -> Note {
        let response: [Note] = try await client
            .from("notes")
            .insert(note)
            .select()
            .execute()
            .value
        
        guard let createdNote = response.first else {
            throw SupabaseError.creationFailed
        }
        
        return createdNote
    }
    
    func updateNote(noteId: Int, note: Note) async throws -> Note {
        let response: [Note] = try await client
            .from("notes")
            .update(note)
            .eq("id", value: noteId)
            .select()
            .execute()
            .value
        
        guard let updatedNote = response.first else {
            throw SupabaseError.updateFailed
        }
        
        return updatedNote
    }
    
    func deleteNote(noteId: Int, userId: String) async throws {
        try await client
            .from("notes")
            .delete()
            .eq("id", value: noteId)
            .eq("user_id", value: userId)
            .execute()
    }
    
    func searchNotes(userId: String, query: String) async throws -> [Note] {
        let allNotes = try await fetchNotes(userId: userId)
        
        // Filter notes locally
        return allNotes.filter { note in
            note.title.localizedCaseInsensitiveContains(query) ||
            note.content.localizedCaseInsensitiveContains(query)
        }
    }
}

enum SupabaseError: LocalizedError {
    case creationFailed
    case updateFailed
    case deletionFailed
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .creationFailed:
            return "Failed to create item in database"
        case .updateFailed:
            return "Failed to update item in database"
        case .deletionFailed:
            return "Failed to delete item from database"
        case .notFound:
            return "Item not found in database"
        }
    }
}

