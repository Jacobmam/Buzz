//
//  User.swift
//  Buzz
//
//  Created by Jacob Mampuya on 17.02.25.
//

import Foundation

struct UserProfile: Identifiable, Equatable, Codable {
    var id: String 
    var username: String
    var ranking: Int
    var gamePoints: Int
    
    init(id: String , username: String, ranking: Int , gamePoints: Int = 0) {
        self.id = id
        self.username = username
        self.ranking = ranking
        self.gamePoints = gamePoints
    }

    mutating func updateUsername(newUsername: String) {
        self.username = newUsername
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "username": username,
            "ranking": ranking,
            "gamePoints": gamePoints
        ]
    }
}
