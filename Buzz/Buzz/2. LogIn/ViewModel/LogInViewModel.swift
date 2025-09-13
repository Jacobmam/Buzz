//
//  LogInViewModel.swift
//  Buzz
//
//  Created by Jacob Mampuya on 21.02.25.
//

import Foundation
import CryptoKit

//@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var loginError: String?
    @Published var isLoading: Bool = false
    @Published var userProfile: UserProfile?
    @Published var recordId: String = ""
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var errorTitle: String = ""
    var isLoggedIn: Bool {
        userProfile != nil
    }
    
    private let database = Firestore.firestore()
    
    func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    func loginValidation() {
        if email.isEmpty || email == ""{
            errorTitle = "Error"
            errorMessage = "Please enter your email"
            showError = true
            return
        }
        if password.isEmpty || password == "" {
            errorTitle = "Error"
            errorMessage = "Please enter your password"
            showError = true
            return
        }
        login() { success, errormessage in
            if success {
                print("✅ Signed in manually")
                // move to home screen
            } else {
                print("❌ Error: \(errormessage ?? "Unknown error")")
                self.errorTitle = "Error"
                self.errorMessage = errormessage ?? ""
                self.showError = true
                return
            }
        }
    }
    
    func login(completion: @escaping (Bool, String?) -> Void) {
        if email.contains("@") {
            if HelperClass.shared.isValidEmail(email) {
                print("valid email")
            } else {
                completion(false, "Please enter a valid email address.")
                return
            }
        }
        self.isLoading = true
        let hashedPassword = hashPassword(password)
        let db = Firestore.firestore()
        db.collection("users")
            .whereField(email.lowercased().contains("@") ? "emailAddress" : "username", isEqualTo: email.lowercased())
            .whereField("isRegistrationCompleted", isEqualTo: true)
            .whereField("password", isEqualTo: hashedPassword)
            .getDocuments { snapshot, error in
                self.isLoading = false
                if let error = error {
                    completion(false, error.localizedDescription)
                    return
                }
                guard let document = snapshot?.documents.first else {
                    completion(false, "User not found, Please check your email/username and password.")
                    return
                }
                
                if var profile = try? document.data(as: UserProfile.self) {
                    if profile.isAccountDeleted == true {
                        completion(false, "User Account Deleted.")
                        return
                    } else {
                        profile.id = document.documentID   // assign Firestore doc ID
                        self.userProfile = profile
                    }
                } else {
                    completion(false, "Failed to decode user profile")
                }
                completion(true, nil)
            }
        
    }
    
    
    
    func loginWithEmail() {
        self.isLoading = true
        loginError = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            self.isLoading = false
            DispatchQueue.main.async {
                if let error = error {
                    self.loginError = error.localizedDescription
                } else if let userId = result?.user.uid {
                    Task {
                        self.userProfile = try await self.find(by: userId)
                    }
                }
            }
        }
    }
    
    func find(by id: String) async throws -> UserProfile? {
        do {
            let snapshot = try await database.collection("users").document(id).getDocument()
            return try snapshot.data(as: UserProfile.self)
        } catch {
            print("Error finding Profile")
            return nil
        }
    }
}

