//
//  StartANewChat.swift
//  Buzz
//
//  Created by Jay Borania on 08/10/25.
//

import SwiftUI

struct StartANewChatView: View {
    @EnvironmentObject private var nav: NavigationManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var startANewChatViewModel = StartANewChatViewModel()
    @EnvironmentObject private var firebaseMessagesHelper: FirebaseMessagesHelper
    var onTapNewUser: ((_ user: User) -> Void)?
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                searchView
                if startANewChatViewModel.isLoading
                {
                    Spacer()
                    ProgressView("Loading...")
                    Spacer()
                } else if let error = startANewChatViewModel.error {
                    Spacer()
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                    Spacer()
                } else {
                    userList
                }
                Spacer()
            }
        }
        .onAppear {
            if startANewChatViewModel.arrUsers.isEmpty {
                if let logindata = UserLoginCache.get() {
                    guard let loginId = logindata.id else { return }
                    startANewChatViewModel.currentUserId = loginId
                }
            }
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
            
            Text("Search Users")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
    }
    var searchView: some View {
        VStack {
            TextField("Search users...", text: $startANewChatViewModel.searchText)
                .showClearButton($startANewChatViewModel.searchText)
                .padding([.leading, .trailing])
                .frame(height: 50)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .autocapitalization(.none)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 0.5)
                }
        }.padding(.horizontal,30)
    }
    
    @ViewBuilder
    var userList: some View {
        if startANewChatViewModel.arrUsers.count > 0 {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(startANewChatViewModel.arrUsers, id: \.self) { user in
                        Button {
                            onTapNewUser?(user)
                            dismiss()
//                            startANewChatViewModel.selectedUser = user
//                            if let searchedUser = startANewChatViewModel.selectedUser {
//                                let searchedUserId = searchedUser.id
//                                if let myId = UserLoginCache.get()?.id {
//                                    firebaseMessagesHelper.fetchOrCreateDirectChat(with: searchedUserId, currentUserId: myId) { room in
//                                        if let room { nav.path.append(Route.messageConversationView(chatRoom: room)) }
//                                    }
//                                }
//                            }
                        } label: {
                            HStack {
                                // display profile image
                                if let imageURL = user.profilePic, imageURL.count > 0 {
                                    AsyncImage(url: URL(string: imageURL),
                                               scale: 1.0,
                                               transaction: .init(animation: .spring())) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .tint(.orange)
                                                .scaleEffect(1)
                                                .transition(.opacity.combined(with: .scale))
                                                .frame(width: 50, height: 50)
                                            
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .transition(.opacity.combined(with: .scale))
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                                .id(imageURL)
                                        case .failure(_):
                                            Color.white.opacity(0.1)
                                        @unknown default:
                                            Color.white.opacity(0.2)
                                        }
                                    }
                                               .scaledToFill()
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.orange)
                                        .tint(.orange)
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                }
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(alignment: .center, spacing: 5) {
                                        Text(user.username)
                                            .foregroundColor(.white)
                                            .padding(.leading, 10)
                                            .fontWeight(.semibold)
                                        
                                        if let basketballPosition = user.basketballPosition {
                                            Text(basketballPosition)
                                                .foregroundColor(.orange)
                                                .fontWeight(.bold)
                                        }
                                        
                                        Spacer()
                                    }
                                    Text("\(user.firstName) \(user.lastName)")
                                        .foregroundColor(.white)
                                        .padding(.leading, 10)
                                        .fontWeight(.light)
                                  
                                }
                                
                                Spacer()
                                Text("#\(user.ranking)")
                                    .foregroundColor(.white)
                                    .padding(.leading, 10)
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .background(.clear)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal, 30)
                        .onAppear {
                            if user == startANewChatViewModel.arrUsers.last {
                                startANewChatViewModel.loadMoreUsers()
                            }
                        }
                    }
                    
                    if startANewChatViewModel.isLoading {
                        ProgressView("Loading more...")
                            .padding()
                    }
                }
                .padding(.top)
            }
        } else {
            VStack {
                Spacer()
                Text("No user found")
                    .foregroundStyle(.gray)
                Spacer()
            }
        }
    }
}
//
//#Preview {
//    StartANewChatView()
//}
