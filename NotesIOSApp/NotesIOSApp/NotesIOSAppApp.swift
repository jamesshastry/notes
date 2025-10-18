//
//  NotesIOSAppApp.swift
//  NotesIOSApp
//
//  Created on 2025-01-01.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct NotesIOSAppApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    // Handle Google Sign-In URL
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

