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
    @Published var id: String = ""
    
    init() {}
    
    func getGamePlayedCount() {
        guard UserLoginCache.get() != nil else { return}
        //        isLoading = true
        let db = Firestore.firestore()
        guard id != "" else { return }
        let userIdQuery =  db.collection("gameHistory")
            .whereField("gameCompleted", isEqualTo: true)
            .whereField("userId", isEqualTo: id)
        let opponentIdQuery =  db.collection("gameHistory")
            .whereField("gameCompleted", isEqualTo: true)
            .whereField("opponentId", isEqualTo: id)
        
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
func getGameWinCount() {
    guard UserLoginCache.get() != nil else { return}
    //        isLoading = true
    let db = Firestore.firestore()
    guard id != "" else { return }

    
    db.collection("gameHistory")
        .whereField("gameCompleted", isEqualTo: true)
        .whereField("userId", isEqualTo: id)
    
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
        .whereField("opponentId", isEqualTo: id)
    
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
}
