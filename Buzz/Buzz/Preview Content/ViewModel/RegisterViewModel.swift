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
    @Published var fullName = ""
    @Published var email = ""
    @Published var birthDate = Date()
    @Published var username = ""
    @Published var password = ""
    @Published var errorMessage: String?

    private let db = Firestore.firestore()

    var isFormValid: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !username.isEmpty &&
        password.count >= 8 &&
        password.first?.isUppercase == true
    }

    func updateFullName() {
        fullName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    func register(completion: @escaping (Bool) -> Void) {
        guard isFormValid else {
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

                self.saveUserData(userId: userId, completion: completion)
            }
        }
    }

    private func saveUserData(userId: String, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("users").document(userId)

        let userData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "fullName": fullName,
            "email": email,
            "birthDate": birthDate.timeIntervalSince1970,
            "username": username
        ]

        userRef.setData(userData) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "❌ Fehler beim Speichern: \(error.localizedDescription)"
                    completion(false)
                } else {
                    print("✅ Nutzer erfolgreich gespeichert")
                    completion(true)
                }
            }
        }
    }
}
