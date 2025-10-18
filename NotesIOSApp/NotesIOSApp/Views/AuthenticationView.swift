//
//  AuthenticationView.swift
//  NotesIOSApp
//
//  Created on 2025-01-01.
//

import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var isLoading = false
    @State private var showError = false
    
    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.4, green: 0.49, blue: 0.92), Color(red: 0.46, green: 0.29, blue: 0.64)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // App icon and title
                VStack(spacing: 15) {
                    Image(systemName: "note.text")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("Notes App")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Sign in to sync your notes")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Sign-in button
                Button(action: {
                    signInWithGoogle()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "globe")
                            .font(.system(size: 20))
                        
                        Text("Sign in with Google")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .disabled(isLoading)
                .padding(.horizontal, 40)
                
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                }
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .alert("Sign-In Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authManager.errorMessage ?? "An unknown error occurred")
        }
    }
    
    private func signInWithGoogle() {
        isLoading = true
        
        Task {
            do {
                try await authManager.signInWithGoogle()
            } catch {
                showError = true
            }
            isLoading = false
        }
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(AuthenticationManager.shared)
}

