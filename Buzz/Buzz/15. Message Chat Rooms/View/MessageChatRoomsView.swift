import SwiftUI

struct MessageChatRoomsView: View {
    @EnvironmentObject private var nav: NavigationManager
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var firebaseMessagesHelper: FirebaseMessagesHelper
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                headerView
                VStack {
                    if (firebaseMessagesHelper.chatRooms.isEmpty  || !firebaseMessagesHelper.chatRooms.contains(where: { !$0.messages.isEmpty })) && !firebaseMessagesHelper.isLoading {
                        Spacer()
                        Text("No chats yet")
                            .foregroundColor(.white)
                        Spacer()
                    } else {
                        List {
                            ForEach(firebaseMessagesHelper.chatRooms, id: \.chatRoomId) { room in
                                if room.messages.count > 0 {
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
                            }
                            
                        }
                        .listStyle(.plain)
                    }
                }
                .background(Color.black.edgesIgnoringSafeArea(.all))
            }
            Button {
                firebaseMessagesHelper.isStartANewChatSheetShowing.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                    .tint(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            }
            .padding([.bottom,.trailing], 30)
            
            if firebaseMessagesHelper.isLoading {
                JBLoadingView()
            }
        }
        .sheet(isPresented: $firebaseMessagesHelper.isStartANewChatSheetShowing) {
            StartANewChatView(
                onTapNewUser: { user in
                    let searchedUserId = user.id
                    if let myId = UserLoginCache.get()?.id {
                        firebaseMessagesHelper.fetchOrCreateDirectChat(with: searchedUserId, currentUserId: myId) { room in
                            if let room { nav.path.append(Route.messageConversationView(chatRoom: room)) }
                        }
                    }
                }
            )
        }
    }
    
    var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .tint(.orange)
                    .frame(height: 20)
                    .bold()
            }
            .frame(width: 50, height: 50)
            
            Text("Messages")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
 
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
    }
}


