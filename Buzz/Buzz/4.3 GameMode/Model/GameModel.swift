//
//  RequestModel.swift
//  Buzz
//
//  Created by Harshil Gajjar on 02/08/25.
//

import Foundation

struct GameModel: Codable, Equatable {
    var userId: String
    var userName: String
    var opponentId: String
    var opponentName: String
    var gameType: String
    var requestStatus: Int
    var gameRequestStatus: GameRequestStatus {
        return GameRequestStatus(rawValue: requestStatus) ?? .pending
    }
    var requestedAt: String
    var historyId: String
}

struct GameHistoryModel: Codable {
    var gameStartedAt: String
    var gameEndedAt: String
    var gameRequestId: String
    var opponentScore: String
    var userScore: String
    var userId: String
    var opponentId: String
    var gameCompleted: Bool
}
