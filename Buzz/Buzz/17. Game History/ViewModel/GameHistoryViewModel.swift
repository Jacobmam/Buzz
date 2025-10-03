//
//  GameHistoryViewModel.swift
//  Buzz
//
//  Created by Jay Borania on 25/09/25.
//

import Foundation

class GameHistoryViewModel: ObservableObject {
    @Published var allGameHistory: [GameHistoryModel] = []
    @Published var isLoading: Bool = false
    
    func fetchGameHistoryWithAllUsers() {
        self.isLoading = true
    
        guard let userDataId = UserLoginCache.get()?.id else { return }
        let db = Firestore.firestore()
        
        db.collection("gameHistory")
            .whereField("gameCompleted", isEqualTo: true)
            .whereFilter(Filter.orFilter([
                Filter.whereField("userId", isEqualTo: userDataId),
                Filter.whereField("opponentId", isEqualTo: userDataId)
            ]))
            .getDocuments { snapshot, error in
                
                guard let docs = snapshot?.documents else { return }
                
                var enrichedGames: [GameHistoryModel] = []
                let outerGroup = DispatchGroup()
                
                for doc in docs {
                    if var game = try? doc.data(as: GameHistoryModel.self) {
                        outerGroup.enter()
                        
                        let innerGroup = DispatchGroup()
                        
                        // fetch user
                        innerGroup.enter()
                        db.collection("users").document(game.userId).getDocument { snap, _ in
                            if let snap, snap.exists {
                                game.user = try? snap.data(as: User.self)
                            }
                            innerGroup.leave()
                        }
                        
                        // fetch opponent
                        innerGroup.enter()
                        db.collection("users").document(game.opponentId).getDocument { snap, _ in
                            if let snap, snap.exists {
                                game.opponent = try? snap.data(as: User.self)
                            }
                            innerGroup.leave()
                        }
                        
                        // after both user & opponent are fetched
                        innerGroup.notify(queue: .main) {
                            enrichedGames.append(game)
                            outerGroup.leave()
                        }
                    }
                }
                
                outerGroup.notify(queue: .main) {
                    self.isLoading = false
                    self.allGameHistory = enrichedGames
                }
            }
    }
    
    
    func formatGameStartedAtDate(_ input: String) -> String? {
        // Input formatter
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS Z"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Convert string to Date
        guard let date = inputFormatter.date(from: input) else {
            return nil
        }
        
        // Output formatter
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM, yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return outputFormatter.string(from: date)
    }

    
    func timeBetween(_ start: String, _ end: String) -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS Z"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        // Parse start and end dates
        guard let startDate = formatter.date(from: start),
              let endDate = formatter.date(from: end) else {
            return nil
        }
        
        // Calculate time interval (in seconds)
        let interval = Int(endDate.timeIntervalSince(startDate))
        
        if interval < 0 {
            return "0s"
        }
        
        let hours = interval / 3600
        let minutes = (interval % 3600) / 60
        let seconds = interval % 60
        
        var components = [String]()
        if hours > 0 { components.append("\(hours)h") }
        if minutes > 0 { components.append("\(minutes)m") }
        if seconds > 0 || components.isEmpty { components.append("\(seconds)s") }
        
        return components.joined(separator: " ")
    }
    
    func getwinnerId(userScore: String, opponentScore: String, userId: String, opponentId: String) -> String {
        if userScore > opponentScore {
            return userId
        } else if userScore < opponentScore {
            return opponentId
        } else {
            return ""
        }
    }
    func getPointsToBeDisplay(gameType: String) -> Int {
        switch gameType {
        case "1v1": return 550
        case "3v3": return 350
        case "5v5": return 750
        default: return 0
        }
    }
    
}
