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
                Image(systemName: "multiply")
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
                List {
                    ForEach(startANewChatViewModel.arrUsers, id: \.self) { user in
                        Button {
                            onTapNewUser?(user)
                            dismiss()
                        } label: {
                            HStack {
                          
                                HStack {
                                    if let imgURL = URL(string: user.profilePic ?? "") {
                                        JBAsyncImage(url: imgURL, placeholder: {
                                            ProgressView()
                                                .tint(.orange)
                                        }, image: {
                                            Image(uiImage: $0).resizable()
                                        })
                                        .scaledToFill()
                                    } else {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundColor(.orange)
                                            .tint(.orange)
                                            .scaledToFill()
                                    }
                                }
                                .clipShape(Circle())
                                .frame(width: 40, height: 40)
                               
                                VStack(alignment: .leading, spacing: 0) {
                                    HStack(alignment: .center, spacing: 5) {
                                        Text(user.username)
                                            .foregroundColor(.white)
                                            .padding(.leading, 10)
                                            .fontWeight(.semibold)
                                        
                                       
                                        
                                        Spacer()
                                        if let basketballPosition = user.basketballPosition {
                                            Text(basketballPosition)
                                                .font(.system(size: 12))
                                                .bold()
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 5)
                                                .background(.orange)
                                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                                .padding(.trailing, 5)
                                        }
                                        Divider()
                                        Text("#\(user.ranking)")
                                            .foregroundColor(.white)
                                            .padding(.leading, 5)
                                            .fontWeight(.medium)
                                    }
                                   
                                    
                                }
                                
                                Spacer()
//
                            }
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
                .listStyle(.plain)
                .padding(.top)
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
