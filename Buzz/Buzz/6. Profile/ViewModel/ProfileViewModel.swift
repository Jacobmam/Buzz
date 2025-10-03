//
//  SettingaViewModel.swift
//  Buzz
//
//  Created by Harshil Gajjar on 04/08/25.
//

import Foundation
import CryptoKit

class ProfileViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isLogoutSuccess: Bool = false
    @Published var isDeleteSuccess: Bool = false
    @Published var fcmTokenRemoved: Bool = false
    @Published var accountDeleted: Bool = false
    @Published var isConfirmationForPassword: Bool = false
    @Published var confirmationPassword: String = ""
    @Published var userData: UserProfile?
    @Published var gamePlayed: Int = 0
    @Published var age: Int?
    @Published var image = UIImage()
    @Published var presentCameraImagePicker: Bool = false
    @Published var imageSourceType: UIImagePickerController.SourceType = .camera
    @Published var profilePic: String = ""
    @Published var errorTitle: String = ""
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    init() {}
    
    func removeUserToken() {
        guard let userId = userData?.id else { return }
        isLoading = true
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "fcmToken": ""
        ]
        
        db.collection("users").document(userId).updateData(data) { error in
            self.isLoading = false
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated fcmToken in users")
                self.fcmTokenRemoved = true
            }
        }
        
    }
    func checkPassword() {
        if userData?.password == hashPassword(confirmationPassword) {
            confirmationPassword = ""
            deleteUserAccount()
        } else {
            confirmationPassword = ""
            self.errorTitle = "Incorrect password"
            self.errorMessage = "Please enter your correct password"
            self.showError = true
        }
        
    }
    func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    func deleteUserAccount() {
        guard let userId = userData?.id else { return }
        isLoading = true
        let db = Firestore.firestore()
        let data: [String: Any] = [
            "fcmToken": "",
            "isAccountDeleted": true
        ]
        db.collection("users").document(userId).updateData(
            data
        ) { error in
            self.isLoading = false
            if let error = error {
                print("Account delete error: \(error)")
            } else {
                print("Success - Deleted user account")
                self.accountDeleted = true
            }
        }
    }
    
    func getGamePlayedCount() {
        guard UserLoginCache.get() != nil else { return}
        isLoading = true
        let db = Firestore.firestore()
        
        guard let userDataId = UserLoginCache.get()?.id else { return}
        let userIdQuery =  db.collection("gameHistory")
            .whereField("gameCompleted", isEqualTo: true)
            .whereField("userId", isEqualTo: userDataId)
        let opponentIdQuery =  db.collection("gameHistory")
            .whereField("gameCompleted", isEqualTo: true)
            .whereField("opponentId", isEqualTo: userDataId)
        
        var allPlayedGames: [QueryDocumentSnapshot] = []
        
        userIdQuery.getDocuments() { snapshot1 ,error in
            self.isLoading = false
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }else {
                guard let asUserPlayed = snapshot1?.documents else { return }
                allPlayedGames.append(contentsOf: asUserPlayed)
            }
            
        }
        opponentIdQuery.getDocuments() { snapshot2 ,error in
            self.isLoading = false
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }else {
                guard let asOpponentPlayed = snapshot2?.documents else { return }
                allPlayedGames.append(contentsOf: asOpponentPlayed)
            }
            let count = allPlayedGames.count
            self.gamePlayed = count
            print("Completed games count: \(count)")
        }
    }
    func getAgeFromBirthdate() {
        guard let dateString = UserLoginCache.get()?.birthDate else {return}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let birthDate = dateFormatter.date(from: dateString) else {
            age = 0
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: now)
        age = max(ageComponents.year ?? 0, 0)  // ensures no negative values
    }
    
    func editProfileData() {
        guard let userId = userData?.id else { return }
        let db = Firestore.firestore()
        self.isLoading = true
        db.collection("users").document(userId).updateData([
            "profilePic": profilePic
        ]) { error in
            self.isLoading = false
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated profile pic in users")
                //
                if var userData = UserLoginCache.get() {
                    userData.profilePic = self.profilePic
                    UserLoginCache.save(userData)
                }
                self.errorTitle = "Success"
                self.errorMessage = "Image Uploaded Successfully!"
                self.showError = true
                
            }
        }
    }
    
    func compressImage(_ image: UIImage, maxHeight: CGFloat = 1024, maxFileSizeKB: Int = 1024) -> UIImage? {
        var newImage = image
        
        // ✅ Step 1: Resize if height > 1024 px
        if image.size.height > maxHeight {
            let scale = maxHeight / image.size.height
            let newWidth = image.size.width * scale
            let newSize = CGSize(width: newWidth, height: maxHeight)
            
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            image.draw(in: CGRect(origin: .zero, size: newSize))
            if let resizedImage = UIGraphicsGetImageFromCurrentImageContext() {
                newImage = resizedImage
            }
            UIGraphicsEndImageContext()
        }
        
        // ✅ Step 2: Compress until under 1024 KB
        var compression: CGFloat = 1.0
        let maxBytes = maxFileSizeKB * 1024
        var imageData = newImage.jpegData(compressionQuality: compression)
        
        while let data = imageData, data.count > maxBytes && compression > 0.1 {
            compression -= 0.1
            imageData = newImage.jpegData(compressionQuality: compression)
        }
        
        if let data = imageData {
            return UIImage(data: data)
        }
        return image
    }
    
   
}
