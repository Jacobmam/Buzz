//
//  GameModeViewModel.swift
//  Buzz
//
//  Created by Harshil Gajjar on 02/08/25.
//

import Foundation

class GameModeViewModel: ObservableObject {
    @Published var selectedMode: String? = nil
    @Published var showAlert: Bool = false
    @Published var requestFailed: Bool = false
    @Published var requestSuccess: Bool = false
    @Published var errorMessage: String = ""
    
    @Published var requestId: String = ""
    
    func selectGameMode(_ mode: String) {
        selectedMode = mode
        print("Selected \(mode) mode")
    }
    
    func sendGameRequest(opponentUser: User) {
        guard let userData = UserLoginCache.get(),
              let selectedMode = selectedMode else {
            self.errorMessage = "Something went wrong"
            self.requestFailed = true
            return
        }
        
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "userId": userData.id,
            "userName": userData.username,
            "opponentId": opponentUser.id,
            "opponentUserName": opponentUser.username,
            "gameType": selectedMode,
            "requestStatus": 0,
            "requestedAt": HelperClass.shared.currentUTCDateString()]
        
        var ref: DocumentReference? = nil
        ref = db.collection("gameRequests").addDocument(data: data) { error in
            if let error = error {
                print("Error sending request: \(error)")
                self.errorMessage = "Something went wrong: \(error.localizedDescription)"
                self.requestFailed = true
            } else {
                self.requestId = ref?.documentID ?? ""
                self.requestSuccess = true
                self.errorMessage = "Game request sent successfully!"
            }
        }
    }
}

