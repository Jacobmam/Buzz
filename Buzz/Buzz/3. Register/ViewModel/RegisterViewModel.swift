//
//  RegisterViewModel.swift
//  Buzz
//
//  Created by Jacob Mampuya on 20.02.25.
//

import SwiftUI
import CryptoKit


enum RegistrationSteps {
    case emailVerification
    case phoneVerification
    case name
    case gender
    case position
    case birthDate
    case username
    case password
}

enum UsernameAvailabilityStatus {
    case none
    case checking
    case available
    case unavailable
    case invalid
}

class RegisterViewModel: ObservableObject {
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var birthDate = Date()
    
    @Published var password = ""
    @Published var gender = "male"
    @Published var isSelectedGenderFemale: Bool = false
    @Published var errorMessage: String?
    @Published var errorTitle: String = ""
    @Published var showError: Bool = false
    @Published var recordId: String = ""
    @Published var registrationSteps: RegistrationSteps = .emailVerification
    @Published var usernameAvailabilityStatus: UsernameAvailabilityStatus = .none
    @Published var emailVerification: EmailVerificationModel = .init(email: "", otp: "")
    @Published var phoneVerification: PhoneVerificationModel = .init(phoneNumber: "", otp: "")
    @Published var isLoading: Bool = false
    
    // Your specific image dimensions
    @Published var imageWidth: CGFloat = 2391
    @Published var imageHeight: CGFloat = 3598
    
    // Define your button positions as percentages
    @Published var buttons = [
        ImageButton(id: 1, x: 0.3, y: 0.11, title: "PF"),
        ImageButton(id: 2, x: 0.7, y: 0.08, title: "SF"),
        ImageButton(id: 3, x: 0.66, y: 0.19, title: "C "),
        ImageButton(id: 4, x: 0.3, y: 0.3, title: "SG"),
        ImageButton(id: 5, x: 0.5, y: 0.32, title: "PG")
    ]
    @Published var selectedPositionButton: ImageButton?
    @Published var testNumbers = [
        "+919999999999",
        "+16505551234"
    ]
    var timerSearchValidation: Timer!
    @Published var username: String = "" {
        didSet {
            self.usernameAvailabilityStatus = .none
            if timerSearchValidation != nil {
                timerSearchValidation.invalidate()
            }
            timerSearchValidation = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(validateUsername), userInfo: nil, repeats: false)
        }
    }
    @objc func validateUsername() {
        guard username.count > 3 else { return }
        if !isValidUsername(username) {
            self.usernameAvailabilityStatus = .invalid
            return
        } else {
            verifyUsername()
        }
    }
    
    func isValidUsername(_ username: String) -> Bool {
        // Regex: only lowercase letters, numbers, dot, underscore
        let regex = "^[a-z0-9._]+$"
        
        // Check against regex
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        let matchesRegex = predicate.evaluate(with: username)
        
        // Ensure no whitespace and not empty
        return matchesRegex && !username.contains(" ")
    }
    
    private let db = Firestore.firestore()
    
    var isFilledOut: Bool {
        !firstName.isEmpty &&
        !lastName.isEmpty &&
        !email.isEmpty &&
        !username.isEmpty &&
        password.count >= 8 &&
        password.first?.isUppercase == true
    }
    
    // MARK: - EMAIL VERIFICATION
    func sendEmailOtp(email: String, completion: @escaping (Bool, String?) -> Void) {
        
        self.emailVerification.isLoading = true
        let functions = Functions.functions(region: "us-central1")
        functions.httpsCallable("sendEmailOtp").call(["email": email.lowercased()] as [String: String]) { result, error in
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
                    self.emailVerification.isLoading = false
                    completion(success, message)
                    
                } else {
                    completion(false, "Unexpected response")
                }
            }
        }
    }
    
    func verifyEmailOtp(email: String, otp: String, completion: @escaping (Bool, String?, String?) -> Void) {
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
    
    
    
    // MARK: - PHONE VERIFICATION
    func phoneNumberValidation() {
        if self.testNumbers.contains(phoneVerification.phoneNumberPlain) {
            self.sendOTPForPhoneNumber()
        } else {
            let db = Firestore.firestore()
            let query = db.collection("users")
                .whereField("phoneNumber", isEqualTo: phoneVerification.phoneNumberPlain)
                .whereField("isPhoneNumberVerified", isEqualTo: true)
            
            query.count.getAggregation(source: .server) { snapshot, error in
                if let error = error {
                    print("Error getting count: \(error)")
                } else if let snapshot = snapshot {
                    print("Count: \(snapshot.count)")
                    if Int(truncating: snapshot.count) >= 1 {
                        self.errorTitle = "Phone numeber already registered"
                        self.errorMessage = "Please use another number to sign up"
                        self.showError = true
                    } else {
                        self.sendOTPForPhoneNumber()
                    }
                }
            }
        }
    }
    
    func sendOTPForPhoneNumber() {
        phoneVerification.isLoading = true
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneVerification.phoneNumberPlain, uiDelegate: nil) { verificationID, error in
            if let error = error {
                self.phoneVerification.isLoading = false
                print("Error: \(error.localizedDescription)")
                self.errorTitle = "Error"
                self.errorMessage = error.localizedDescription
                self.showError = true
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            print("OTP Sent to phone ✅")
            self.phoneVerification.isLoading = false
            self.phoneVerification.isPhoneNumberVerificationCodeSent = true
        }
    }
    
    func verifyOTPForPhoneNumber() {
        phoneVerification.isLoading = true
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: phoneVerification.otp
        )
        
        Auth.auth().signIn(with: credential) { result, error in
            self.phoneVerification.isLoading = false
            if let error = error {
                
                print("OTP Verification Failed: \(error.localizedDescription)")
            } else {
                print("Phone Verified ✅")
                self.updatePhoneNumber()
            }
        }
    }
    
    func getRegistrationStepNumber() -> String {
        switch registrationSteps {
        case .emailVerification:
            return "1"
        case .phoneVerification:
            return "2"
        case .name:
            return "3"
        case .gender:
            return "4"
        case .position:
            return "5"
        case .birthDate:
            return "6"
        case .username:
            return "7"
        case .password:
            return "8"
        }
    }
    
    func updatePhoneNumber() {
        let db = Firestore.firestore()
        db.collection("users").document(recordId).updateData([
            "phoneNumber": phoneVerification.phoneNumberPlain,
            "countryCode": phoneVerification.country?.dial_code ?? "",
            "isPhoneNumberVerified": true,
            "id": recordId,
            "gamePoints": 0,
            "ranking": 0
            
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated PhoneNumber in user")
                self.phoneVerification.isPhoneNumberVerified = true
                self.registrationSteps = .name
            }
        }
    }
    func validateFirstAndLastName() {
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorTitle = "Error"
            showError = true
            errorMessage = "Please enter firstname."
            return
        }
        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorTitle = "Error"
            showError = true
            errorMessage = "Please enter lastname."
            return
        }
        
        updateFirstAndLastNameInUser()
    }
    
    func updateFirstAndLastNameInUser() {
        let db = Firestore.firestore()
        isLoading = true
        db.collection("users").document(recordId).updateData([
            "firstName": firstName,
            "lastName": lastName
        ]) { error in
            self.isLoading = false
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated FirstAndLastName in users")
                self.registrationSteps = .gender
            }
        }
    }
    
    func updateGender() {
        let db = Firestore.firestore()
        self.isLoading = true
        db.collection("users").document(recordId).updateData([
            "gender": self.gender
        ]) { error in
            self.isLoading = false
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated Gender in users")
                self.registrationSteps = .position
            }
        }
    }
    func updatePosition() {
        let db = Firestore.firestore()
        
        self.isLoading = true
        if self.selectedPositionButton != nil {
            db.collection("users").document(recordId).updateData([
                "basketballPosition": self.selectedPositionButton?.title ?? ""
            ]) { error in
                self.isLoading = false
                if let error = error {
                    print("Error updating document: \(error)")
                } else {
                    print("Success - Updated Gender in users")
                    self.registrationSteps = .birthDate
                }
            }
        } else {
            self.errorTitle = "Empty Position"
            self.errorMessage = "Please select a position"
            self.showError = true
        }
    }
    func updateUsername() {
        let db = Firestore.firestore()
        self.isLoading = true
        db.collection("users").document(recordId).updateData([
            "username": self.username
        ]) { error in
            self.isLoading = false
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated username in users")
                self.registrationSteps = .password
            }
        }
    }
    func updateBirthdate() {
        let db = Firestore.firestore()
        self.isLoading = true
        db.collection("users").document(recordId).updateData([
            "birthDate": formattedDate(date: self.birthDate)
        ]) { error in
            self.isLoading = false
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated birthdate in users")
                self.registrationSteps = .username
            }
        }
    }
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // "dd" for day, "MM" for month, "yyyy" for year
        return formatter.string(from: date)
    }
    
    func verifyUsername() {
        self.usernameAvailabilityStatus = .checking
        let db = Firestore.firestore()
        let query = db.collection("users")
            .whereField("username", isEqualTo: username)
        
        query.count.getAggregation(source: .server) { snapshot, error in
            if let error = error {
                print("Error getting count: \(error)")
            } else if let snapshot = snapshot {
                print("Count: \(snapshot.count)")
                if Int(truncating: snapshot.count) == 0 {
                    self.usernameAvailabilityStatus = .available
                } else {
                    self.usernameAvailabilityStatus = .unavailable
                }
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
            "isRegistrationCompleted": true
        ]) { error in
            self.isLoading = false
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated birthdate in users")
                //                self.registrationSteps = .username
                self.errorTitle = "Registration Complete"
                self.errorMessage = "Please login to continue."
                self.showError = true
            }
        }
    }
    
}
