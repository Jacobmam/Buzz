//
//  RequestViewModel.swift
//  Buzz
//
//  Created by Harshil Gajjar on 02/08/25.
//

import Foundation

class RequestViewModel: ObservableObject {
    @Published var sentRequests: [RequestModel] = []
    @Published var receivedRequests: [RequestModel] = []
    @Published var isLoading = false
    @Published var responseMessage: String?
    @Published var showResponseMessage = false
    
    @Published var acceptedRequestId: String = ""
    @Published var gameHistoryId: String = ""
    @Published var navigateToGameScoreboardView: Bool = false
    
    private let db = Firestore.firestore()
    
    func fetchRequests(for currentUserId: String) {
        isLoading = true
        sentRequests = []
        receivedRequests = []
        responseMessage = nil
        
        let dispatchGroup = DispatchGroup()
        
        // Fetch Sent
        dispatchGroup.enter()
        db.collection("gameRequests")
            .whereField("userId", isEqualTo: currentUserId)
            .whereField("requestStatus", isEqualTo: 0)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                guard error == nil, let documents = snapshot?.documents else {
                    self.responseMessage = "Failed to fetch sent: \(error?.localizedDescription ?? "")"
                    dispatchGroup.leave()
                    return
                }
                
                let group = DispatchGroup()
                var tempSent: [RequestModel] = []
                
                for doc in documents {
                    let data = doc.data()
                    let requestId = doc.documentID
                    let opponentId = data["opponentId"] as? String ?? ""
                    let userId = data["userId"] as? String ?? ""
                    let gameType = data["gameType"] as? String ?? ""
                    let requestStatus = data["requestStatus"] as? Int ?? 0
                    let requestedAt = data["requestedAt"] as? String ?? ""
                    
                    group.enter()
                    self.db.collection("users").document(opponentId).getDocument { snap, _ in
                        let username = snap?.data()?["username"] as? String ?? "Unknown"
                        tempSent.append(RequestModel(id: requestId, userId: userId, opponentId: opponentId, opponentUsername: username, gameType: gameType, requestStatus: requestStatus, requestedAt: requestedAt))
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.sentRequests = tempSent
                    dispatchGroup.leave()
                }
            }
        
        // Fetch Received
        dispatchGroup.enter()
        db.collection("gameRequests")
            .whereField("opponentId", isEqualTo: currentUserId)
            .whereField("requestStatus", isEqualTo: 0)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                guard error == nil, let documents = snapshot?.documents else {
                    self.responseMessage = "Failed to fetch received: \(error?.localizedDescription ?? "")"
                    dispatchGroup.leave()
                    return
                }
                
                let group = DispatchGroup()
                var tempReceived: [RequestModel] = []
                
                for doc in documents {
                    let data = doc.data()
                    let requestId = doc.documentID
                    let userId = data["userId"] as? String ?? ""
                    let opponentId = data["opponentId"] as? String ?? ""
                    let gameType = data["gameType"] as? String ?? ""
                    let requestStatus = data["requestStatus"] as? Int ?? 0
                    let requestedAt = data["requestedAt"] as? String ?? ""
                    
                    group.enter()
                    self.db.collection("users").document(userId).getDocument { snap, _ in
                        let username = snap?.data()?["username"] as? String ?? "Unknown"
                        tempReceived.append(RequestModel(id: requestId, userId: userId, opponentId: opponentId, opponentUsername: username, gameType: gameType, requestStatus: requestStatus, requestedAt: requestedAt))
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    self.receivedRequests = tempReceived
                    dispatchGroup.leave()
                }
            }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
        }
    }
    
    func changeRequestStatus(_ request: RequestModel, _ status: GameRequestStatus) {
        let db = Firestore.firestore()
        
        var data: [String: Any] = [
            "requestStatus": status.rawValue,
        ]
        
        db.collection("gameRequests").document(request.id).updateData(data) { error in
            if let error = error {
                print("Error updating document: \(error)")
                self.responseMessage = "Error updating document: \(error)"
                self.showResponseMessage = true
            } else {
                if let index = self.receivedRequests.firstIndex(where: { $0.id == request.id }) {
                    self.receivedRequests.remove(at: index)
                    print("Request removed from local array.")
                } else {
                    print("Request not found in array.")
                }
                print("Request accepted")
                self.acceptedRequestId = ""
                
                switch status {
                case .accepted:
                    self.acceptedRequestId = request.id
                    self.createGameHistory(request.id)
                case .rejected, .pending, .cancelled:
                    break
                case .completed:
                    break
                @unknown default:
                    break
                }
                
            }
        }
    }
    
    func createGameHistory(_ gameRequestId: String) {
        let db = Firestore.firestore()

        let data: [String: Any] = [
            "gameRequestId": gameRequestId,
        ]
        
        var ref: DocumentReference? = nil
        ref = db.collection("gameHistory").addDocument(data: data) { error in
            if let error = error {
                print("Error adding game history: \(error.localizedDescription)")
            } else {
                print("Game history created with ID: \(ref!.documentID)")
                self.gameHistoryId = ref?.documentID ?? ""
                self.updateGameHistoryIdInGameRequest(gameRequestId)
            }
        }
    }
    
    func updateGameHistoryIdInGameRequest(_ requestId: String) {
        let db = Firestore.firestore()
        db.collection("gameRequests").document(requestId).updateData([
            "historyId": self.gameHistoryId
        ]) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated historyId in gameRequest")
                self.responseMessage = "Request accepted"
                self.showResponseMessage = true
            }
        }
    }
}
