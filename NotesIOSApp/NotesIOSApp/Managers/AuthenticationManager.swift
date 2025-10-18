//
//  AuthenticationManager.swift
//  NotesIOSApp
//
//  Created on 2025-01-01.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                
                if let user = user {
                    print("✅ User authenticated: \(user.email ?? "no email")")
                    // Ensure user profile exists in Supabase
                    await self?.ensureUserProfile(user: user)
                } else {
                    print("❌ User not authenticated")
                }
            }
        }
    }
    
    func signInWithGoogle() async throws {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = await windowScene.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        // Get the Firebase client ID from the configuration
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.noClientID
        }
        
        // Configure Google Sign-In
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            // Start the sign-in flow
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.noIDToken
            }
            
            let accessToken = result.user.accessToken.tokenString
            
            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // Sign in to Firebase
            let authResult = try await Auth.auth().signIn(with: credential)
            
            print("✅ Successfully signed in: \(authResult.user.email ?? "no email")")
            
            self.currentUser = authResult.user
            self.isAuthenticated = true
            self.errorMessage = nil
            
        } catch {
            print("❌ Sign-in error: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func signOut() async throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            
            self.currentUser = nil
            self.isAuthenticated = false
            self.errorMessage = nil
            
            print("✅ Successfully signed out")
        } catch {
            print("❌ Sign-out error: \(error.localizedDescription)")
            self.errorMessage = error.localizedDescription
            throw error
        }
    }
    
    private func ensureUserProfile(user: User) async {
        guard let email = user.email else { return }
        
        do {
            // Check if profile exists
            let existingProfile: UserProfile? = try await SupabaseManager.shared.fetchUserProfile(userId: user.uid)
            
            if existingProfile == nil {
                // Create new profile
                let newProfile = UserProfile(
                    userId: user.uid,
                    email: email,
                    name: user.displayName,
                    isPremium: false,
                    premiumSince: nil,
                    createdAt: Date()
                )
                
                try await SupabaseManager.shared.createUserProfile(profile: newProfile)
                print("✅ User profile created in Supabase")
            } else {
                print("✅ User profile already exists in Supabase")
            }
        } catch {
            print("❌ Error ensuring user profile: \(error.localizedDescription)")
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

enum AuthError: LocalizedError {
    case noRootViewController
    case noClientID
    case noIDToken
    
    var errorDescription: String? {
        switch self {
        case .noRootViewController:
            return "Could not find root view controller"
        case .noClientID:
            return "Firebase client ID not found"
        case .noIDToken:
            return "Google Sign-In ID token not found"
        }
    }
}

