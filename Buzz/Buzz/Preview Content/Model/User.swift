//
//  User.swift
//  Buzz
//
//  Created by Jacob Mampuya on 17.02.25.
//

import SwiftUI

struct UserProfile {
    var id: UUID = UUID()
    var username: String
    var ranking: Int
    var gamePoints: Int
    
    init(username: String, ranking: Int = 1, gamePoints: Int = 450) {
        self.username = username
        self.ranking = ranking
        self.gamePoints = gamePoints
    }
    
    mutating func updateUsername(newUsername: String) {
        self.username = newUsername
    }
}
