import SwiftUI

struct MessageChatRoomsView: View {
    @EnvironmentObject private var nav: NavigationManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var firebaseMessagesHelper: FirebaseMessagesHelper

    var body: some View {
        VStack {
            if firebaseMessagesHelper.chatRooms.isEmpty {
                Text("No chats yet")
                    .foregroundColor(.white)
            } else {
                List {
                    ForEach(firebaseMessagesHelper.chatRooms, id: \.chatRoomId) { room in
                        Button {
                            nav.path.append(Route.messageConversationView(chatRoom: room))
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(room.user?.username ?? "Chat")
                                        .foregroundColor(.white)
                                    Text(room.messages.first?.message ?? "No messages yet")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(formatChatDate(room.messages.first?.createdAt ?? room.lastUpdatedAt ?? ""))
                                        .foregroundColor(.orange)
                                        .font(.caption2)
                                }
                            }
                        }
                        .onAppear {
                            // Load more when the last item appears
                            if room.id == firebaseMessagesHelper.chatRooms.last?.id {
                                firebaseMessagesHelper.loadMoreChatRooms()
                            }
                        }
                    }
                    
                    // Loading indicator
                    if firebaseMessagesHelper.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .tint(.orange)
                            Spacer()
                        }
                        .padding()
                    }
                }
                .listStyle(.plain)
                .background(Color.black)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationTitle("Messages")
        .toolbar { ToolbarItem(placement: .topBarLeading) { Button(action: { dismiss() }) { Image(systemName: "chevron.left") } } }
    }
    
    private func formatChatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return "" }
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return timeFormatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM"
            return dateFormatter.string(from: date)
        }
    }
}


