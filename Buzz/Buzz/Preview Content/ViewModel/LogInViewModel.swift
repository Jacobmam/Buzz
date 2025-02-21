//
//  LogInViewModel.swift
//  Buzz
//
//  Created by Jacob Mampuya on 21.02.25.
//

import SwiftUI
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var loginError: String?
    
    func loginWithEmail() {
        guard !email.isEmpty, !password.isEmpty else {
            loginError = "Bitte alle Felder ausfüllen."
            return
        }
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    self.loginError = "Fehler beim Login: \(error.localizedDescription)"
                } else {
                    print("✅ Erfolgreich eingeloggt als \(authResult?.user.email ?? "Unbekannt")")
                }
            }
        }
    }
    
}

