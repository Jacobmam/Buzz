//
//  ForgotPasswordViewModel.swift
//  Buzz
//
//  Created by Jay Borania on 04/09/25.
//

import Foundation
import CryptoKit

class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var otp = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var isEmailVerificationCodeSentForForgotPassword = false
    @Published var isEmailVerified = false
    @Published var emailVerification: EmailVerificationModel = .init(email: "", otp: "")
    @Published var errorMessage: String?
    @Published var errorTitle: String = ""
    @Published var showError: Bool = false
    @Published var recordId: String = ""

    
    func sendForgotPasswordEmailOtp(email: String, completion: @escaping (Bool, String?) -> Void) {
        self.emailVerification.isLoading = true
        let functions = Functions.functions(region: "us-central1")
        functions.httpsCallable("sendForgotPasswordEmailOtp").call(["email": email] as [String: String]) { result, error in
            DispatchQueue.main.async {
                self.emailVerification.isLoading = false
            }
            if let error = error {
                print("Error sending OTP: \(error.localizedDescription)")
                completion(false, error.localizedDescription)
                return
            } else {
                if let data = result?.data as? [String: Any],
                   let success = data["success"] as? Bool,
                   let message = data["message"] as? String {
                    completion(success, message)
                } else {
                    completion(false, "Unexpected response")
                }
            }
        }
    }
    func verifyForgotPasswordEmailOtp(email: String, otp: String, completion: @escaping (Bool, String?, String?) -> Void) {
        self.emailVerification.isLoading = true
        Functions.functions().httpsCallable("verifyEmailOtp").call(["email": email, "otp": otp]) { result, error in
            DispatchQueue.main.async {
                self.emailVerification.isLoading = false
            }
            if let error = error {
                print("Error verifying OTP: \(error.localizedDescription)")
                completion(false, error.localizedDescription, "")
                return
            }
            if let data = result?.data as? [String: Any],
               let verified = data["verified"] as? Bool, verified {
                print("Email verified ✅  for data: \(data)")
                completion(true, "Email verified ✅  for data: \(data)" , data["recordId"] as? String ?? "")
            } else {
                completion(false, "Invalid OTP", "")
            }
        }
    }
    func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    func updatePassword() {
        let db = Firestore.firestore()
        self.isLoading = true
        db.collection("users").document(recordId).updateData([
            "password": hashPassword(password),
        ]) { error in
            self.isLoading = false
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated Password in users")
                //                self.registrationSteps = .username
                self.errorTitle = "Password Updated"
                self.errorMessage = "Please login to continue."
                self.showError = true

            }
        }
    }
    
}
