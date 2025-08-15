//
//  SettingaViewModel.swift
//  Buzz
//
//  Created by Harshil Gajjar on 04/08/25.
//

import Foundation

class SettingsViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var isLogoutSuccess: Bool = false
    @Published var fcmTokenRemoved: Bool = false
    init() {}
    
    func removeUserToken() {
        guard let userData = UserLoginCache.get() else { return }
        isLoading = true
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "fcmToken": ""
        ]
        
        db.collection("users").document(userData.id).updateData(data) { error in
            self.isLoading = false
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated fcmToken in users")
                self.fcmTokenRemoved = true
            }
        }
    }
}
