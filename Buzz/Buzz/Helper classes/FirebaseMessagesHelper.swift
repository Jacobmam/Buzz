//
//  FirebaseMessagesHelper.swift
//  Buzz
//
//  Recreated by Assistant on 02/10/25.
//

import Foundation
import FirebaseFirestore

class FirebaseMessagesHelper: ObservableObject {
    private let db = Firestore.firestore()
    private let messagePageSize = 10
    private let chatRoomPageSize = 10
    private let messageThreshold = 3 // Load more when 3rd message from top appears

    @Published var isLoading: Bool = false
    @Published var isLoadingMoreMessages: Bool = false
    @Published var chatRooms: [ChatRoomModel] = []
    @Published var totalUnreadCount: Int = 0
    @Published var hasMoreChatRooms: Bool = true
    private var currentUserId: String?
    private var lastChatRoomDocument: QueryDocumentSnapshot?

    private var chatRoomsListener: ListenerRegistration?
    private var messageListeners: [String: ListenerRegistration] = [:]
    private var chatRoomPagination: [String: QueryDocumentSnapshot] = [:]
    
    // Track which chat rooms are currently marked as read by the user
//    private var readChatRooms: Set<String> = []
    
    // Track message counts to detect new messages
    private var chatRoomMessageCounts: [String: Int] = [:]
    
    // Track currently active conversation
    private var activeConversationId: String?

    private func mapUser(from data: [String: Any], id: String) -> User {
        let username = data["username"] as? String ?? ""
        let ranking = data["ranking"] as? Int ?? 0
        let gamePoints = data["gamePoints"] as? Int ?? 0
        let profilePic = data["profilePic"] as? String
        let firstName = data["firstName"] as? String ?? ""
        let lastName = data["lastName"] as? String ?? ""
        let basketballPosition = data["basketballPosition"] as? String
        return User(id: id, username: username, ranking: ranking, gamePoints: gamePoints, profilePic: profilePic, firstName: firstName, lastName: lastName, basketballPosition: basketballPosition)
    }

    func stopAllListeners() {
        chatRoomsListener?.remove()
        chatRoomsListener = nil
        for (_, listener) in messageListeners { listener.remove() }
        messageListeners.removeAll()
    }
    
    func clearUserData() {
        stopAllListeners()
        chatRooms.removeAll()
        totalUnreadCount = 0
        hasMoreChatRooms = true
        isLoadingMoreMessages = false
        currentUserId = nil
        lastChatRoomDocument = nil
        chatRoomPagination.removeAll()
//        readChatRooms.removeAll()
        chatRoomMessageCounts.removeAll()
        activeConversationId = nil
    }

    // MARK: - Chat room discovery (or creation)
    func fetchOrCreateDirectChat(with otherUserId: String, currentUserId: String, completion: @escaping (ChatRoomModel?) -> Void) {
        let participants1 = [currentUserId, otherUserId]
        let participants2 = [otherUserId, currentUserId]

        db.collection("chats")
            .whereField("participants", in: [participants1, participants2])
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error { print("fetchOrCreateDirectChat error: \(error)"); completion(nil); return }
                if let doc = snapshot?.documents.first {
                    let chatRoomId = doc.documentID
                    let participants = doc.get("participants") as? [String] ?? []
                    let room = ChatRoomModel(chatRoomId: chatRoomId, participant: participants, messages: [], lastDocument: nil, lastUpdatedAt: doc.get("lastUpdatedAt") as? String, unreadCount: 0, user: nil)
                    completion(room)
                    return
                }

                // Create new direct chat
                let payload: [String: Any] = [
                    "participants": participants1,
                    "type": "direct",
                    "lastUpdatedAt": HelperClass.shared.currentUTCDateString()
                ]
                self.db.collection("chats").addDocument(data: payload) { err in
                    if let err = err { print("create chat error: \(err)"); completion(nil); return }
                    // Requery to get doc id
                    self.db.collection("chats")
                        .whereField("participants", isEqualTo: participants1)
                        .limit(to: 1)
                        .getDocuments { snap, _ in
                            if let created = snap?.documents.first {
                                let room = ChatRoomModel(chatRoomId: created.documentID, participant: participants1, messages: [], lastDocument: nil, lastUpdatedAt: created.get("lastUpdatedAt") as? String, unreadCount: 0, user: nil)
                                completion(room)
                            } else { completion(nil) }
                        }
                }
            }
    }

    // MARK: - Observe all chat rooms for a user
    func observeChatRooms(for userId: String) {
        stopAllListeners()
        
        // Clear previous user's data when switching users
        if currentUserId != userId {
            chatRooms.removeAll()
            totalUnreadCount = 0
            hasMoreChatRooms = true
            lastChatRoomDocument = nil
//            readChatRooms.removeAll()
            chatRoomMessageCounts.removeAll()
            activeConversationId = nil
        }
        
//        isLoading = true
        currentUserId = userId

        chatRoomsListener = db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error { print("observeChatRooms error: \(error)"); /*self.isLoading = false;*/ return }
                guard let docs = snapshot?.documents else { /*self.isLoading = false;*/ return }

                var rooms: [ChatRoomModel] = []
                for doc in docs {
                    let chatRoomId = doc.documentID
                    let participants = doc.get("participants") as? [String] ?? []
                    let lastUpdatedAt = doc.get("lastUpdatedAt") as? String
                    let room = ChatRoomModel(chatRoomId: chatRoomId, participant: participants, messages: [], lastDocument: nil, lastUpdatedAt: lastUpdatedAt, unreadCount: 0, user: nil)

                    // Fetch other participant's user profile
                    if let me = self.currentUserId, let otherId = participants.first(where: { $0 != me }) {
                        self.db.collection("users").document(otherId).getDocument { snap, _ in
                            if let snap, snap.exists, let data = snap.data() {
                                let user = self.mapUser(from: data, id: snap.documentID)
                                DispatchQueue.main.async {
                                    if let idx = self.chatRooms.firstIndex(where: { $0.chatRoomId == chatRoomId }) {
                                        self.chatRooms[idx].user = user
                                    }
                                }
                            }
                        }
                    }

                    rooms.append(room)

                    // Attach message listener
                    observeMessages(for: chatRoomId)
                }

                // Sort by lastUpdatedAt desc
                rooms.sort { ($0.lastUpdatedAt ?? "") > ($1.lastUpdatedAt ?? "") }
                DispatchQueue.main.async {
                    for room in rooms {
                        if !self.chatRooms.contains(room) {
                            self.chatRooms.append(room)
                        }
                    }
                }
            }
    }
    
    // MARK: - Load more chat rooms for pagination
    func loadMoreChatRooms() {
        guard let currentUserId = currentUserId, 
              hasMoreChatRooms,
              !isLoading else { return }
        
        isLoading = true
        
        var query = db.collection("chats")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "lastUpdatedAt", descending: true)
            .limit(to: chatRoomPageSize)
        
        if let lastDoc = lastChatRoomDocument {
            query = query.start(afterDocument: lastDoc)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error { 
                print("loadMoreChatRooms error: \(error)")
                return 
            }
            
            guard let docs = snapshot?.documents else { return }
            
            if docs.count < self.chatRoomPageSize {
                self.hasMoreChatRooms = false
            }
            
            self.lastChatRoomDocument = docs.last
            
            var newRooms: [ChatRoomModel] = []
            for doc in docs {
                let chatRoomId = doc.documentID
                let participants = doc.get("participants") as? [String] ?? []
                let lastUpdatedAt = doc.get("lastUpdatedAt") as? String
                let room = ChatRoomModel(chatRoomId: chatRoomId, participant: participants, messages: [], lastDocument: nil, lastUpdatedAt: lastUpdatedAt, unreadCount: 0, user: nil)

                // Fetch other participant's user profile
                if let me = self.currentUserId, let otherId = participants.first(where: { $0 != me }) {
                    self.db.collection("users").document(otherId).getDocument { snap, _ in
                        if let snap, snap.exists, let data = snap.data() {
                            let user = self.mapUser(from: data, id: snap.documentID)
                            DispatchQueue.main.async {
                                if let idx = self.chatRooms.firstIndex(where: { $0.chatRoomId == chatRoomId }) {
                                    self.chatRooms[idx].user = user
                                }
                            }
                        }
                    }
                }

                newRooms.append(room)

                // Attach message listener
                self.observeMessages(for: chatRoomId)
            }

            DispatchQueue.main.async {
                self.chatRooms.append(contentsOf: newRooms)
                // Sort by lastUpdatedAt desc
                self.chatRooms.sort { ($0.lastUpdatedAt ?? "") > ($1.lastUpdatedAt ?? "") }
            }
        }
    }

    // MARK: - Observe messages in a room and compute unread
    func observeMessages(for chatRoomId: String) {
//        isLoading = true
        if let existing = messageListeners[chatRoomId] { existing.remove() }

        let listener = db.collection("chats").document(chatRoomId).collection("messages")
            .order(by: "createdAt", descending: true)
            .limit(to: messagePageSize)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error { print("observeMessages error: \(error)"); return }
                guard let documents = snapshot?.documents else { return }

                let messages: [MessageModel] = documents.compactMap { doc in
                    let data = doc.data()
                    return MessageModel(
                        messageId: data["messageId"] as? String ?? doc.documentID,
                        message: data["message"] as? String ?? "",
                        senderId: data["senderId"] as? String ?? "",
                        receiverId: data["receiverId"] as? String,
                        createdAt: data["createdAt"] as? String ?? "",
                        status: MessageStatus(rawValue: data["status"] as? String ?? MessageStatus.sent.rawValue) ?? .sent
                    )
                    
                }

                DispatchQueue.main.async {
                    if let idx = self.chatRooms.firstIndex(where: { $0.chatRoomId == chatRoomId }) {
                        let previousMessageCount = self.chatRoomMessageCounts[chatRoomId] ?? 0
                        let newMessageCount = messages.count
                        let hasNewMessages = newMessageCount > previousMessageCount
                        
                        // Update message count tracking
                        self.chatRoomMessageCounts[chatRoomId] = newMessageCount
                        
                        // If new messages arrived and this chat was marked as read, unmark it
                        // but only if the new message is not from the current user AND this is not the active conversation
//                        if hasNewMessages && self.readChatRooms.contains(chatRoomId) {
//                            let latestMessage = messages.first
//                            let isFromCurrentUser = latestMessage?.senderId == self.currentUserId
//                            let isActiveConversation = self.activeConversationId == chatRoomId
//
//                            if !isFromCurrentUser && !isActiveConversation {
//                                print("isActiveConversation: New message from another user detected (not in active conversation), unmarking chat as read")
//                                self.readChatRooms.remove(chatRoomId)
//                            } else {
//                                print("isActiveConversation: user is in active conversation")
//                            }
//                            // Do not auto-mark as read for active conversation here; the view will decide
//                        }
                        
                        self.chatRooms[idx].messages = messages
                        self.chatRooms[idx].lastUpdatedAt = messages.first?.createdAt
                        self.chatRooms[idx].lastDocument = documents.last
                        
                        // compute unread per room
                        if let me = self.currentUserId {
                            let unread = messages.filter { $0.receiverId == me && $0.status != .read }.count
                            let currentUnread = self.chatRooms[idx].unreadCount ?? 0
//                            let isMarkedAsRead = self.readChatRooms.contains(chatRoomId)
                            
                            print("📊 observeMessages - chatRoom: \(chatRoomId)")
                            print("📊 Calculated unread from Firebase: \(unread)")
                            print("📊 Current local unread count: \(currentUnread)")
//                            print("📊 Is marked as read locally: \(isMarkedAsRead)")
                            print("📊 Has new messages: \(hasNewMessages)")
                            
                            // If the chat room is marked as read locally, keep unread count at 0
                            // Otherwise, update with the calculated unread count
//                            if isMarkedAsRead {
//                                self.chatRooms[idx].unreadCount = 0
//                                print("📊 Keeping unread count at 0 (chat marked as read)")
//                            } else {
                            if self.activeConversationId != self.chatRooms[idx].chatRoomId {
                                self.chatRooms[idx].unreadCount = unread
                                print("📊 Updated unread count to: \(unread)")
                            }
//                            }
                        }
                        // Resort rooms by latest message
                        self.chatRooms.sort { ($0.lastUpdatedAt ?? "") > ($1.lastUpdatedAt ?? "") }
                        // compute total unread
                        self.totalUnreadCount = self.chatRooms.reduce(0) { $0 + ($1.unreadCount ?? 0) }
                    }
                }
            }

        messageListeners[chatRoomId] = listener
//        isLoading = false
    }
    
    // MARK: - Load more messages for pagination
    func loadMoreMessages(for chatRoomId: String) {
        guard let roomIndex = chatRooms.firstIndex(where: { $0.chatRoomId == chatRoomId }),
              let lastDocument = chatRooms[roomIndex].lastDocument,
              !isLoadingMoreMessages else { return }
        
        isLoadingMoreMessages = true
        
        db.collection("chats").document(chatRoomId).collection("messages")
            .order(by: "createdAt", descending: true)
            .start(afterDocument: lastDocument)
            .limit(to: messagePageSize)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.isLoadingMoreMessages = false
                }
                
                if let error = error { 
                    print("loadMoreMessages error: \(error)")
                    return 
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else { 
                    // No more messages available
                    DispatchQueue.main.async {
                        if let idx = self.chatRooms.firstIndex(where: { $0.chatRoomId == chatRoomId }) {
                            self.chatRooms[idx].hasMoreMessages = false
                        }
                    }
                    return 
                }
                
                let newMessages: [MessageModel] = documents.compactMap { doc in
                    let data = doc.data()
                    return MessageModel(
                        messageId: data["messageId"] as? String ?? doc.documentID,
                        message: data["message"] as? String ?? "",
                        senderId: data["senderId"] as? String ?? "",
                        receiverId: data["receiverId"] as? String,
                        createdAt: data["createdAt"] as? String ?? "",
                        status: MessageStatus(rawValue: data["status"] as? String ?? MessageStatus.sent.rawValue) ?? .sent
                    )
                }
                
                DispatchQueue.main.async {
                    if let idx = self.chatRooms.firstIndex(where: { $0.chatRoomId == chatRoomId }) {
                        self.chatRooms[idx].messages.append(contentsOf: newMessages)
                        self.chatRooms[idx].lastDocument = documents.last
                        // If we got fewer messages than requested, we've reached the end
                        if newMessages.count < self.messagePageSize {
                            self.chatRooms[idx].hasMoreMessages = false
                        }
                    }
                }
            }
    }

    // MARK: - Send message
    func sendMessage(_ text: String, in chatRoomId: String, senderId: String, receiverId: String?) {
        let messageId = UUID().uuidString
        let createdAt = HelperClass.shared.currentUTCDateString()
        let payload: [String: Any] = [
            "messageId": messageId,
            "message": text,
            "senderId": senderId,
            "receiverId": receiverId ?? "",
            "createdAt": createdAt,
            "status": MessageStatus.sent.rawValue
        ]

        db.collection("chats").document(chatRoomId).collection("messages").addDocument(data: payload) { [weak self] err in
            if let err = err { print("sendMessage error: \(err)"); return }
            self?.db.collection("chats").document(chatRoomId).setData(["lastUpdatedAt": createdAt], merge: true)
        }
    }

    // MARK: - Set active conversation
    func setActiveConversation(_ chatRoomId: String?) {
        activeConversationId = chatRoomId
        print("💬 Set active conversation: \(chatRoomId ?? "none")")
    }
    
    // MARK: - Unmark chat room as read (when new messages arrive)
    func unmarkChatRoomAsRead(chatRoomId: String) {
//        readChatRooms.remove(chatRoomId)
        print("🔄 Removed chatRoom from read set: \(chatRoomId)")
    }
    
    // MARK: - Mark messages as read for current user
    func markMessagesRead(for chatRoomId: String, userId: String) {
        print("🔵 markMessagesRead called for chatRoom: \(chatRoomId), user: \(userId)")
        
        // First, immediately update the local state for better UX
        DispatchQueue.main.async {
            if let idx = self.chatRooms.firstIndex(where: { $0.chatRoomId == chatRoomId }) {
                let oldUnreadCount = self.chatRooms[idx].unreadCount ?? 0
                let oldTotalCount = self.totalUnreadCount
                
                // Count how many messages we're about to mark as read
                let unreadMessagesToMark = self.chatRooms[idx].messages.filter { 
                    $0.receiverId == userId && $0.status != .read 
                }.count
                
                print("🔵 Found \(unreadMessagesToMark) unread messages to mark as read")
                print("🔵 Old unread count for this room: \(oldUnreadCount)")
                print("🔵 Old total unread count: \(oldTotalCount)")
                
                if unreadMessagesToMark > 0 {
                    // Update message status in local cache immediately
                    for i in 0..<self.chatRooms[idx].messages.count {
                        if self.chatRooms[idx].messages[i].receiverId == userId && 
                           self.chatRooms[idx].messages[i].status != .read {
                            self.chatRooms[idx].messages[i].status = .read
                        }
                    }
                    
                    // Set unread count to 0 for this chat room
                    self.chatRooms[idx].unreadCount = 0
                    
                    // Mark this chat room as read locally
//                    self.readChatRooms.insert(chatRoomId)
                    
                    // Recalculate total unread count
                    self.totalUnreadCount = self.chatRooms.reduce(0) { $0 + ($1.unreadCount ?? 0) }
                    
                    print("🟢 New unread count for this room: \(self.chatRooms[idx].unreadCount ?? 0)")
                    print("🟢 New total unread count: \(self.totalUnreadCount)")
                    print("🟢 Added chatRoom to read set: \(chatRoomId)")
                } else {
                    print("🟡 No unread messages found to mark as read")
                }
            } else {
                print("🔴 Chat room not found in local cache")
            }
        }
        
        // Then update Firebase in the background
        let messagesRef = db.collection("chats").document(chatRoomId).collection("messages")
        messagesRef
            .whereField("receiverId", isEqualTo: userId)
            .whereField("status", isEqualTo: MessageStatus.sent.rawValue)
            .getDocuments { snap, _ in
                guard let docs = snap?.documents else { return }
                
                // Mark messages as read in Firebase
                for doc in docs {
                    doc.reference.setData(["status": MessageStatus.read.rawValue], merge: true)
                }
            }
    }
}


