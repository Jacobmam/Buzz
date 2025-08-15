//
//  RequestModel.swift
//  Buzz
//
//  Created by Harshil Gajjar on 02/08/25.
//
import Foundation

struct RequestModel: Identifiable {
    var id: String
    var userId: String
    var opponentId: String
    var opponentUsername: String
    var gameType: String
    var requestStatus: Int
    var requestedAt: String
}
