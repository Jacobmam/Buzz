//
//  SearchUserProfileViewModel.swift
//  Buzz
//
//  Created by Jay Borania on 10/09/25.
//

class SearchUserProfileViewModel: ObservableObject {
    @Published var gamePlayed: Int = 0
    @Published var gameWins: Int = 0
    @Published var isLoading: Bool = false
    @Published var selectedUser: User?
    @Published var userData: UserProfile?
    @Published var allGameHistory: [GameHistoryModel] = []

    
    @Published var countCheckParticipants: Int = 2
    private let pageSize = 10
    private var isFetching = false
    var canLoadMore = true
    init() {}

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    func getGamePlayedCount(searchedUserId: String) {
        guard UserLoginCache.get() != nil else { return}
        //        isLoading = true
        let db = Firestore.firestore()
        guard searchedUserId != "" else { return }
        let userIdQuery =  db.collection("gameHistory")
            .whereField("gameCompleted", isEqualTo: true)
            .whereField("userId", isEqualTo: searchedUserId)
        let opponentIdQuery =  db.collection("gameHistory")
            .whereField("gameCompleted", isEqualTo: true)
            .whereField("opponentId", isEqualTo: searchedUserId)
        
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
    func getGameWinCount(searchedUserId: String) {
        guard UserLoginCache.get() != nil else { return}
        let db = Firestore.firestore()
        guard searchedUserId != "" else { return }
        
        
        db.collection("gameHistory")
            .whereField("gameCompleted", isEqualTo: true)
            .whereField("userId", isEqualTo: searchedUserId)
        
            .getDocuments() { snapshot,error in
                //                self.isLoading = false
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                } else {
                    guard let documents = snapshot?.documents else { return }
                    
                    let matchingGames = documents.filter { doc in
                        let userScoreStr = doc.get("userScore") as? String ?? "0"
                        let opponentScoreStr = doc.get("opponentScore") as? String ?? "0"
                        
                        // Convert strings to Int
                        let userScore = Int(userScoreStr) ?? 0
                        let opponentScore = Int(opponentScoreStr) ?? 0
                        
                        return userScore > opponentScore
                    }
                    
                    let count1 = matchingGames.count
                    //                       let count = snapshot?.documents.count ?? 0
                    self.gameWins = count1
                    print("Completed games count: \(count1)")
                }
            }
        
        db.collection("gameHistory")
            .whereField("gameCompleted", isEqualTo: true)
            .whereField("opponentId", isEqualTo: searchedUserId)
        
            .getDocuments() { snapshot,error in
                //                self.isLoading = false
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                } else {
                    guard let documents = snapshot?.documents else { return }
                    
                    let matchingGames = documents.filter { doc in
                        let userScoreStr = doc.get("userScore") as? String ?? "0"
                        let opponentScoreStr = doc.get("opponentScore") as? String ?? "0"
                        
                        // Convert strings to Int
                        let userScore = Int(userScoreStr) ?? 0
                        let opponentScore = Int(opponentScoreStr) ?? 0
                        
                        return userScore < opponentScore
                    }
                    
                    let count2 = matchingGames.count
                    //                       let count = snapshot?.documents.count ?? 0
                    self.gameWins += count2
                    print("Completed games count: \(count2)")
                }
            }
    }
    
        
        func fetchGameHistoryWithSearchedUser(userID: String, searchedUserId: String) {
            let db = Firestore.firestore()
            var enrichedGames: [GameHistoryModel] = []
            let outerGroup = DispatchGroup()
            
            // Query 1: searchedUser vs current user
            outerGroup.enter()
            db.collection("gameHistory")
                .whereField("gameCompleted", isEqualTo: true)
                .whereField("userId", isEqualTo: searchedUserId)
                .whereField("opponentId", isEqualTo: userID)
                .getDocuments { snapshot, _ in
                    if let docs = snapshot?.documents {
                        self.decodeAndEnrich(docs, db: db) { games in
                            enrichedGames.append(contentsOf: games)
                            outerGroup.leave()
                        }
                    } else {
                        outerGroup.leave()
                    }
                }
            
            // Query 2: current user vs searchedUser
            outerGroup.enter()
            db.collection("gameHistory")
                .whereField("gameCompleted", isEqualTo: true)
                .whereField("userId", isEqualTo: userID)
                .whereField("opponentId", isEqualTo: searchedUserId)
                .getDocuments { snapshot, _ in
                    if let docs = snapshot?.documents {
                        self.decodeAndEnrich(docs, db: db) { games in
                            enrichedGames.append(contentsOf: games)
                            outerGroup.leave()
                        }
                    } else {
                        outerGroup.leave()
                    }
                }
            
            // When both queries done
            outerGroup.notify(queue: .main) {
                self.allGameHistory = enrichedGames
            }
        }
        
        private func decodeAndEnrich(
            _ docs: [QueryDocumentSnapshot],
            db: Firestore,
            completion: @escaping ([GameHistoryModel]) -> Void
        ) {
            var games: [GameHistoryModel] = []
            let group = DispatchGroup()
            
            for doc in docs {
                if var game = try? doc.data(as: GameHistoryModel.self) {
                    group.enter()
                    
                    let innerGroup = DispatchGroup()
                    
                    // user
                    innerGroup.enter()
                    db.collection("users").document(game.userId).getDocument { snap, _ in
                        if let snap, snap.exists {
                            game.user = try? snap.data(as: User.self)
                        }
                        innerGroup.leave()
                    }
                    
                    // opponent
                    innerGroup.enter()
                    db.collection("users").document(game.opponentId).getDocument { snap, _ in
                        if let snap, snap.exists {
                            game.opponent = try? snap.data(as: User.self)
                        }
                        innerGroup.leave()
                    }
                    
                    innerGroup.notify(queue: .main) {
                        games.append(game)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                completion(games)
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
