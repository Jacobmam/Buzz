//
//  MessageModel.swift
//  Buzz
//
//  Created by Assistant on 02/10/25.
//

import Foundation

enum MessageStatus: String, Codable, Hashable {
    case sent
    case delivered
    case read
}

struct MessageModel: Identifiable, Codable, Hashable {
    var id: String { messageId }
    let messageId: String
    let message: String
    let senderId: String
    let receiverId: String?
    let createdAt: String
    var status: MessageStatus
}


