//
//  ChatRoomModel.swift
//  Buzz
//
//  Created by Assistant on 02/10/25.
//

import Foundation
import FirebaseFirestore

struct ChatRoomModel: Identifiable, Hashable {
    var id: String { chatRoomId }
    let chatRoomId: String
    let participant: [String]
    var messages: [MessageModel]
    var lastDocument: QueryDocumentSnapshot?
    var lastUpdatedAt: String?
    var unreadCount: Int?
    var user: User?
    var hasMoreMessages: Bool = true
    var unreadMessagesCount: Int = 0
    
    static func == (lhs: ChatRoomModel, rhs: ChatRoomModel) -> Bool {
        return lhs.chatRoomId == rhs.chatRoomId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(chatRoomId)
    }
}


