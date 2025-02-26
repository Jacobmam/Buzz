//
//  LogInViewModel.swift
//  Buzz
//
//  Created by Jacob Mampuya on 21.02.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var loginError: String?
    @Published var isLoading: Bool = false
    @Published var userProfile: UserProfile?
    var isLoggedIn: Bool {
        userProfile != nil
        
    }
    
    private let database = Firestore.firestore()
    
    
    func loginWithEmail() {
        isLoading = true
        loginError = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.loginError = error.localizedDescription
                } else if let userId = result?.user.uid {
                    Task {
                        try await self.find(by: userId)
                    }
                }
            }
        }
    }
    
    func find(by id: String) async throws {
        do {
            let snapshot = try await database.collection("users").document(id).getDocument()
            self.userProfile = try snapshot.data(as: UserProfile.self)
        } catch {
            print("Error finding Profile")
        }
    }
}

