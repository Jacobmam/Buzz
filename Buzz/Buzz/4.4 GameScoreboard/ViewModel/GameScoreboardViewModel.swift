//
//  GameScoreboardViewModel.swift
//  Buzz
//
//  Created by Harshil Gajjar on 03/08/25.
//


import Foundation
import Combine

class GameScoreboardViewModel: ObservableObject {
    @Published var txtMyScore: String = ""
    @Published var txtOpponentScore: String = ""
    @Published var gameRequestData: GameModel?
    @Published var gameHistoryData: GameHistoryModel?
    @Published var timerString: String = "00:00"
    
    @Published var showRequestCancelResponseAlert: Bool = false
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    private var cancellable: AnyCancellable?
    private var seconds = 0
    
    // 1
    func fetchGameRequestData(_ requestId: String) {
        guard let userData = UserLoginCache.get() else { return }
        db.collection("gameRequests").document(requestId)
            .getDocument { requestDoc, error in
                if let data = requestDoc?.data() {
                    print("fetchGameRequestData: \(data)")
                    let opponentId = data["opponentId"] as? String ?? ""
                    let opponentUserName = data["opponentUserName"] as? String ?? ""
                    let userId = data["userId"] as? String ?? ""
                    let userName = data["userName"] as? String ?? ""
                    let gameType = data["gameType"] as? String ?? ""
                    let requestStatus = data["requestStatus"] as? Int ?? 0
                    let requestedAt = data["requestedAt"] as? String ?? ""
                    let historyId = data["historyId"] as? String ?? ""
                    
                    self.gameRequestData = GameModel(userId: userId,
                                                     userName: userName,
                                                     opponentId: opponentId,
                                                     opponentName: opponentUserName,
                                                     gameType: gameType,
                                                     requestStatus: requestStatus,
                                                     requestedAt: requestedAt,
                                                     historyId: historyId)
                    self.observeGameRequest(requestId)
                }
            }
    }
    
    // 2
    func observeGameRequest(_ requestId: String) {
        listener = db.collection("gameRequests").document(requestId).addSnapshotListener { requestDoc, error in
            
            if let data = requestDoc?.data() {
                print("observeGameRequest: \(data)")
                let requestStatus = data["requestStatus"] as? Int ?? 0
                let historyId = data["historyId"] as? String ?? ""
                
                if requestStatus != self.gameRequestData?.requestStatus {
                    self.gameRequestData?.requestStatus = requestStatus
                }
                
                if historyId.count > 0 {
                    self.gameRequestData?.historyId = historyId
                    self.fetchGameHistory(self.gameRequestData?.historyId ?? "")
                }
            }
        }
    }
    
    // 3
    func fetchGameHistory(_ historyId: String) {
        db.collection("gameHistory").document(historyId)
            .getDocument { requestDoc, error in
                if let data = requestDoc?.data() {
                    print("fetchGameHistory: \(data)")
                    let gameStartedAt = data["gameStartedAt"] as? String ?? ""
                    let gameEndedAt = data["gameEndedAt"] as? String ?? ""
                    let gameRequestId = data["gameRequestId"] as? String ?? ""
                    let opponentScore = data["opponentScore"] as? String ?? ""
                    let userScore = data["userScore"] as? String ?? ""
                    let userId = data["userId"] as? String ?? ""
                    let opponentId = data["opponentId"] as? String ?? ""
                    let gameCompleted = data["gameCompleted"] as? Bool ?? false
                    
                    self.gameHistoryData = nil
                    self.gameHistoryData = GameHistoryModel(gameStartedAt: gameStartedAt,
                                                            gameEndedAt: gameEndedAt,
                                                            gameRequestId: gameRequestId,
                                                            opponentScore: opponentScore,
                                                            userScore: userScore,
                                                            userId: userId,
                                                            opponentId: opponentId,
                                                            gameCompleted: gameCompleted)
                    self.observeGameHistory()
                }
            }
    }
    
    // 4
    func observeGameHistory() {
        listener = db.collection("gameHistory").document(self.gameRequestData?.historyId ?? "").addSnapshotListener { requestDoc, error in
            
            if let data = requestDoc?.data() {
                print("observeGameHistory: \(data)")
                let gameStartedAt = data["gameStartedAt"] as? String ?? ""
                let gameEndedAt = data["gameEndedAt"] as? String ?? ""
                let gameRequestId = data["gameRequestId"] as? String ?? ""
                let opponentScore = data["opponentScore"] as? String ?? ""
                let userScore = data["userScore"] as? String ?? ""
                let userId = data["userId"] as? String ?? ""
                let opponentId = data["opponentId"] as? String ?? ""
                let gameCompleted = data["gameCompleted"] as? Bool ?? false
                
                if !gameStartedAt.isEmpty &&
                    (self.gameHistoryData?.gameStartedAt ?? "").isEmpty {
                    self.gameHistoryData?.gameStartedAt = gameStartedAt
                    self.startTimer()
                }
                
                if !gameEndedAt.isEmpty &&
                    (self.gameHistoryData?.gameEndedAt ?? "").isEmpty {
                    self.gameHistoryData?.gameEndedAt = gameEndedAt
                    self.stopTimer()
                }
                
                if gameCompleted == true &&
                    self.gameHistoryData?.gameCompleted != true {
                    self.gameHistoryData?.gameCompleted = gameCompleted
                }
                
                if !userScore.isEmpty {
                    self.gameHistoryData?.userScore = userScore
                }
                
                if !opponentScore.isEmpty {
                    self.gameHistoryData?.opponentScore = opponentScore
                }
                
                if !userId.isEmpty {
                    self.gameHistoryData?.userId = userId
                }
                
                if !opponentId.isEmpty {
                    self.gameHistoryData?.opponentId = opponentId
                }
                
                print("observed gameHistoryData: \(String(describing: self.gameHistoryData))")
            }
        }
    }
    
    // 5
    func updateGameStartTimeInHistory() {
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "gameStartedAt": HelperClass.shared.currentUTCDateString()
        ]
        
        db.collection("gameHistory").document(gameRequestData?.historyId ?? "").updateData(data) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated gameStartedAt in gameHistory")
            }
        }
    }
    
    // 6
    func startTimer() {
        guard let startTime = gameHistoryData?.gameStartedAt, !startTime.isEmpty else { return }
        seconds = HelperClass.shared.secondsSince(startDateString: startTime) ?? 0
        timerString = formatTime(seconds)
        
        cancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.seconds += 1
                self.timerString = self.formatTime(self.seconds)
            }
    }
    
    // 6.1
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // 7
    func updateGameEndTimeInHistory() {
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "gameEndedAt": HelperClass.shared.currentUTCDateString()
        ]
        
        db.collection("gameHistory").document(gameRequestData?.historyId ?? "").updateData(data) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated gameEndedAt in gameHistory")
            }
        }
    }
    
    // 8
    func stopTimer() {
        cancellable?.cancel()
        print("Timer stopped")
    }
    
    // 9
    func updateGameCompletedFlagInHistory() {
        let db = Firestore.firestore()
        
        let data: [String: Any] = [
            "gameCompleted": true
        ]
        
        db.collection("gameHistory").document(gameRequestData?.historyId ?? "").updateData(data) { error in
            if let error = error {
                print("Error updating document: \(error)")
            } else {
                print("Success - Updated gameCompleted in gameHistory")
            }
        }
    }
    
    // 10
    func updateGameScores(_ gameRequestId: String) {
        guard let userData = UserLoginCache.get() else { return }
        let db = Firestore.firestore()
        
        let updateData: [String: Any] = [
            "userScore": (userData.id == gameRequestData?.userId) ? txtMyScore : txtOpponentScore,
            "opponentScore": (userData.id == gameRequestData?.userId) ? txtOpponentScore : txtMyScore,
            "userId": gameRequestData?.userId ?? "",
            "opponentId": gameRequestData?.opponentId ?? "",
        ]
        
        db.collection("gameHistory").document(self.gameRequestData?.historyId ?? "").updateData(updateData) { error in
            if let error = error {
                print("Error updating scores: \(error.localizedDescription)")
            } else {
                print("Scores updated successfully.")
                self.updateRequestStatus(.completed, requestId: gameRequestId)
            }
        }
    }
    
    // 11
    func updateRequestStatus(_ status: GameRequestStatus, requestId: String) {
        
        let data: [String: Any] = [
            "requestStatus": status.rawValue,
        ]
        
        db.collection("gameRequests").document(requestId).updateData(data) { error in
            if let error = error {
                print("Error updating Request status: \(error)")
            } else {
                print("Request status successfully updated! - \(status.rawValue)")
                self.gameRequestData?.requestStatus = status.rawValue
                
                switch status {
                case .accepted, .rejected, .pending: break
                case .cancelled:
                    self.showRequestCancelResponseAlert.toggle()
                case .completed:
                    self.updateGamePointsForWinner()
                }
            }
        }
    }
    
    // 12
    func whatIsMyResult() -> String {
        guard gameHistoryData != nil && !(gameHistoryData?.userScore ?? "").isEmpty && !(gameHistoryData?.opponentScore ?? "").isEmpty else { return "" }
        if let userData = UserLoginCache.get() {
            
            let myScore = (userData.id == gameHistoryData?.userId) ? gameHistoryData?.userScore ?? "0" : gameHistoryData?.opponentScore ?? "0"
            let opponentScore = (userData.id == gameHistoryData?.userId) ? gameHistoryData?.opponentScore ?? "0" : gameHistoryData?.userScore ?? "0"
            
            DispatchQueue.main.async {
                // TO UPDATE SCORE IN OTHER PLAYER'S SCREEN
                self.txtMyScore = myScore
                self.txtOpponentScore = opponentScore
            }
            
            let intMyScore: Int = Int(myScore) ?? 0
            let intOpponentScore: Int = Int(opponentScore) ?? 0
            
            if intMyScore > intOpponentScore {
                return "win"
            } else if intMyScore < intOpponentScore {
                return "lose"
            } else if intMyScore == intOpponentScore {
                return "tie"
            }
        }
        return ""
    }
    
    // 13
    func updateGamePointsForWinner() {
        guard whatIsMyResult() == "win" else { return }
        guard var userData = UserLoginCache.get() else { return }
        db.collection("users").document(userData.id)
            .getDocument { requestDoc, error in
                if let data = requestDoc?.data() {
                    print("updateGamePointsForWinner: \(data)")
                    let gamePoints = data["gamePoints"] as? Int ?? 0
                    let pointToBeAdded = gamePoints + self.getPointsToBeAdded()
                    
                    let dataToUpdate: [String: Any] = [
                        "gamePoints": pointToBeAdded
                    ]
                    
                    self.db.collection("users").document(userData.id).updateData(dataToUpdate) { error in
                        if let error = error {
                            print("Error updating document: \(error)")
                        } else {
                            print("Success - Updated gamePoints in users id: \(userData.id)")
                            userData.gamePoints = pointToBeAdded
                            UserLoginCache.save(userData)
                        }
                    }
                }
            }
    }
    
    // 13.1
    func getPointsToBeAdded() -> Int {
        switch self.gameRequestData?.gameType {
        case "1v1": return 550
        case "3v3": return 350
        case "5v5": return 750
        default: return 0
        }
    }
    
}
