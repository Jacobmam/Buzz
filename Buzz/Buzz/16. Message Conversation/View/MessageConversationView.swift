import SwiftUI

struct MessageConversationView: View {
    let chatRoom: ChatRoomModel
    @EnvironmentObject private var firebaseMessagesHelper: FirebaseMessagesHelper
    @State private var text: String = ""
    @State private var currentDateBadge: String = ""
    @Environment(\.dismiss) private var dismiss

    private var liveRoom: ChatRoomModel? {
        firebaseMessagesHelper.chatRooms.first(where: { $0.chatRoomId == chatRoom.chatRoomId })
    }

    private var messages: [MessageModel] {
        // Return messages in ascending order (oldest first, newest last)
        return (liveRoom?.messages ?? []).reversed()
    }

    private var otherUserName: String {
        liveRoom?.user?.username ?? chatRoom.user?.username ?? "Chat"
    }

    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                if let myUserId = UserLoginCache.get()?.id {
                    List {
                        ForEach((liveRoom?.messages ?? []), id: \.messageId) { msg in
                            HStack {
                                if msg.senderId == myUserId {
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(msg.message)
                                            .padding(8)
                                            .background(Color.orange.opacity(0.3))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        Text(formatDate(msg.createdAt))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                } else {
                                    VStack(alignment: .leading) {
                                        Text(msg.message)
                                            .padding(8)
                                            .background(Color.gray.opacity(0.3))
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                        Text(formatDate(msg.createdAt))
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                }
                            }
                            .id(msg.messageId)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5))
                            .rotationEffect(.degrees(180))
                            .onAppear {
                                // Update date badge based on visible message
                                updateDateBadge(for: msg.createdAt)

                                // Load older messages when reaching near the top of the inverted list
                                if let arr = liveRoom?.messages,
                                   let idx = arr.firstIndex(where: { $0.messageId == msg.messageId }),
                                   idx >= (arr.count - 3),
                                   let room = liveRoom,
                                   room.hasMoreMessages && !firebaseMessagesHelper.isLoadingMoreMessages {
                                    firebaseMessagesHelper.loadMoreMessages(for: chatRoom.chatRoomId)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .rotationEffect(.degrees(180))
                }
                HStack {
                    TextField("Message", text: $text)
                        .textFieldStyle(.roundedBorder)
                    Button("Send") {
                        guard let senderId = UserLoginCache.get()?.id else { return }
                        let receiverId = liveRoom?.participant.first(where: { $0 != senderId })
                        firebaseMessagesHelper.sendMessage(text.trimmingCharacters(in: .whitespacesAndNewlines), in: chatRoom.chatRoomId, senderId: senderId, receiverId: receiverId)
                        text = ""
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding()
            }

         
            
            // Sticky date badge at the top
            if !currentDateBadge.isEmpty {
                HStack {
                    Spacer()
                    Text(currentDateBadge)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.8))
                        .cornerRadius(15)
                    Spacer()
                }
                .padding(.top, 10)
            }
        }
        .navigationTitle(otherUserName)
        .toolbar { ToolbarItem(placement: .topBarLeading) { Button(action: { dismiss() }) { Image(systemName: "chevron.left") } } }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            // Set this as the active conversation
            firebaseMessagesHelper.setActiveConversation(chatRoom.chatRoomId)
            
            // Mark messages as read
            if let me = UserLoginCache.get()?.id { 
                firebaseMessagesHelper.markMessagesRead(for: chatRoom.chatRoomId, userId: me) 
            }
        }
        .onDisappear {
            // Clear active conversation when leaving
            firebaseMessagesHelper.setActiveConversation(nil)
        }
    }

    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "" }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "HH:mm"
        return displayFormatter.string(from: date)
    }
    
    private func updateDateBadge(for dateString: String) {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return }
        
        let calendar = Calendar.current
        let now = Date()
        
        let newBadge: String
        if calendar.isDateInToday(date) {
            newBadge = "Today"
        } else if calendar.isDateInYesterday(date) {
            newBadge = "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            let currentYear = calendar.component(.year, from: now)
            let messageYear = calendar.component(.year, from: date)
            
            if currentYear == messageYear {
                dateFormatter.dateFormat = "d MMM"
            } else {
                dateFormatter.dateFormat = "d MMM yyyy"
            }
            newBadge = dateFormatter.string(from: date)
        }
        
        if currentDateBadge != newBadge {
            currentDateBadge = newBadge
        }
    }
}


