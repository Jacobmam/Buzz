//
//  RegisterViewModel.swift
//  Buzz
//
//  Created by Jacob Mampuya on 20.02.25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class RegisterViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var birthDate = Date()
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    var isFilledOut: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !username.isEmpty &&
        password.count >= 8 &&
        password.first?.isUppercase == true
    }


    func register(completion: @escaping (Bool) -> Void) {
        guard isFilledOut else {
            DispatchQueue.main.async {
                self.errorMessage = "⚠️ Bitte alle Felder korrekt ausfüllen."
            }
            completion(false)
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "❌ Fehler bei Registrierung: \(error.localizedDescription)"
                    completion(false)
                    return
                }

                guard let userId = authResult?.user.uid else {
                    self.errorMessage = "❌ Unbekannter Fehler"
                    completion(false)
                    return
                }
                
                Task {
                    try await self.saveUserData(userId: userId)
                }
            }
        }
    }

    private func saveUserData(userId: String) async throws {
        
        let userRef = db.collection("users").document(userId)

        
        let userProfile = UserProfile(id: userId,username: username, ranking: 99)
        
        do {
            try userRef.setData(from: userProfile)
        } catch {
            print("Error crreation Profile")
        
        }
    

        
    }
}
