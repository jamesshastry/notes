import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    var currentUser: User? {
        return Auth.auth().currentUser
    }
    
    var currentUserId: String? {
        return Auth.auth().currentUser?.uid
    }
    
    var currentUserEmail: String? {
        return Auth.auth().currentUser?.email
    }
    
    var currentUserName: String? {
        return Auth.auth().currentUser?.displayName
    }
    
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    // MARK: - Google Sign In
    
    func signInWithGoogle(presenting viewController: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase client ID not found"])))
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ Google Sign-In error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get ID token"])))
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print("❌ Firebase authentication error: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let firebaseUser = authResult?.user else {
                    completion(.failure(NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase user not found"])))
                    return
                }
                
                print("✅ User signed in: \(firebaseUser.email ?? "unknown")")
                completion(.success(firebaseUser))
            }
        }
    }
    
    // MARK: - Sign Out
    
    func signOut(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            print("✅ User signed out successfully")
            completion(.success(()))
        } catch {
            print("❌ Sign out error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Auth State Listener
    
    func addAuthStateListener(listener: @escaping (User?) -> Void) -> AuthStateDidChangeListenerHandle {
        return Auth.auth().addStateDidChangeListener { _, user in
            listener(user)
        }
    }
    
    func removeAuthStateListener(handle: AuthStateDidChangeListenerHandle) {
        Auth.auth().removeStateDidChangeListener(handle)
    }
}

