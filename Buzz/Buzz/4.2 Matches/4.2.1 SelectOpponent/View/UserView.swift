//
//  UserView.swift
//  Buzz
//
//  Created by Harshil Gajjar on 01/08/25.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject private var nav: NavigationManager
    @StateObject private var userViewModel = UserViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                
                VStack {
                    searchView
                    
                    if userViewModel.isLoading &&
                        userViewModel.arrUsers.isEmpty {
                        Spacer()
                        ProgressView("Loading...")
                        Spacer()
                    } else if let error = userViewModel.error {
                        Spacer()
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                        Spacer()
                    } else {
                        userList
                    }
                }
                .onAppear {
                    if userViewModel.arrUsers.isEmpty {
                        if let logindata = UserLoginCache.get() {
                            userViewModel.currentUserId = logindata.id
                            userViewModel.fetchUsers()
                        }
                    }
                }
            }
        }
    }
    
    var searchView: some View {
        VStack {
            TextField("Search Opponent...", text: $userViewModel.searchText)
                .showClearButton($userViewModel.searchText)
                .padding([.leading, .trailing])
                .frame(height: 50)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .autocapitalization(.words)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 0.5)
                }
        }.padding(.horizontal,30)
    }
    
    @ViewBuilder
    var userList: some View {
        if userViewModel.arrUsers.count > 0 {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(userViewModel.arrUsers, id: \.self) { user in
                        Button {
                            userViewModel.opponentUser = user
                        } label: {
                            HStack {
                                Text(user.username)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: (userViewModel.opponentUser == user) ? "checkmark.square.fill" : "square")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.white)
                                    .frame(height: 22)
                            }
                            .padding()
                            .background((userViewModel.opponentUser == user) ? .orange : .clear)
                            .cornerRadius(10)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(lineWidth: 0.5)
                                    .fill(.white)
                            }
                        }
                        .padding(.horizontal, 30)
                        .onAppear {
                            if user == userViewModel.arrUsers.last {
                                userViewModel.loadMoreUsers()
                            }
                        }
                    }
                    
                    if userViewModel.isLoading {
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
            
            Text("Select Opponent")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
            
            Button {
                if let opponentUser = userViewModel.opponentUser {
                    nav.path.append(Route.gameModeView(opponentUser: opponentUser))
                }
            } label: {
                Text("NEXT")
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                    .foregroundStyle(.white)
            }
            .background(.orange)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(userViewModel.opponentUser == nil)
            .opacity(userViewModel.opponentUser == nil ? 0.5 : 1.0)
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
        
    }
}



#Preview {
    UserView()
}
