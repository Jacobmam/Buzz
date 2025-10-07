import SwiftUI

struct MessageChatRoomsView: View {
    @EnvironmentObject private var nav: NavigationManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var firebaseMessagesHelper: FirebaseMessagesHelper

    var body: some View {
        ZStack {
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
                                HStack(alignment: .top, spacing: 16) {
                                    if let strURL = room.user?.profilePic,
                                       let imageURL = URL(string: strURL) {
                                        JBAsyncImage(url: imageURL, placeholder: {
                                            ProgressView()
                                                .tint(.orange)
                                        }, image: {
                                            Image(uiImage: $0).resizable()
                                        })
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                    } else {
                                        ZStack {
                                            Image(systemName: "person.fill")
                                                .resizable()
                                                .scaledToFit()
                                                .tint(.white)
                                                .frame(width: 20, height: 20)
                                            
                                        }
                                        .frame(width: 50, height: 50)
                                        .background(.white.opacity(0.5))
                                        .clipShape(Circle())
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(room.user?.username ?? "")
                                            .foregroundColor(.white)
                                            .font(.system(size: 16, weight: .semibold))
                                        
                                        Text(room.messages.first?.message ?? "No messages yet")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14))
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 0) {
                                        Text(HelperClass.shared.formattedDateForChatRoom(room.messages.first?.createdAt ?? room.lastUpdatedAt ?? ""))
                                            .foregroundColor((room.unreadCount ?? 0) > 0 ? .orange : .white.opacity(0.8))
                                            .font(.system(size: 14))
                                        
                                        if let unreadCount = room.unreadCount,
                                           unreadCount > 0 {
                                            Text("\(unreadCount)")
                                                .font(.system(size: 14))
                                                .foregroundStyle(.white)
                                                .padding(6)
                                                .background(.orange)
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                                .frame(height: 50)
                            }
                            .onAppear {
                                // Load more when the last item appears
                                if room.id == firebaseMessagesHelper.chatRooms.last?.id {
                                    firebaseMessagesHelper.loadMoreChatRooms()
                                }
                            }
                        }
                        
                        // Loading indicator
//                        if firebaseMessagesHelper.isLoading {
//                            HStack {
//                                Spacer()
//                                ProgressView()
//                                    .tint(.orange)
//                                Spacer()
//                            }
//                            .padding()
//                        }
                    }
                    .listStyle(.plain)
                    .background(Color.black)
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationTitle("Messages")
            .toolbar { ToolbarItem(placement: .topBarLeading) { Button(action: { dismiss() }) { Image(systemName: "chevron.left") } } }
            
//            if firebaseMessagesHelper.isLoading {
//                JBLoadingView()
//            }
        }
    }
}


