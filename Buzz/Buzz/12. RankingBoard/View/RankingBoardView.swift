//
//  RankingBoardView.swift
//  Buzz
//
//  Created by Jay Borania on 13/08/25.
//

import SwiftUI

struct RankingBoardView: View {
    @EnvironmentObject private var nav: NavigationManager
    @StateObject private var rankingBoardViewModel = RankingBoardViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            headerView
            
            if rankingBoardViewModel.isLoading &&
                rankingBoardViewModel.arrUsers.isEmpty {
                Spacer()
                ProgressView("Loading...")
                Spacer()
            } else if let error = rankingBoardViewModel.error {
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
            rankingBoardViewModel.fetchUsers()
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
            
            Text("Ranking Board")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
    }
    
    var userList: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(rankingBoardViewModel.arrUsers, id: \.self) { user in
                    HStack {
                        Text("\(user.ranking)")
                            .foregroundColor(.white)
                        
                        Text(user.username)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(user.gamePoints)")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background((UserLoginCache.get()?.id == user.id) ? .orange : .clear)
                    .cornerRadius(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 0.5)
                            .fill(.white)
                    }
                    .padding(.horizontal, 30)
                    .onAppear {
                        if let lastUser = rankingBoardViewModel.arrUsers.last,
                           user == lastUser {
                            rankingBoardViewModel.loadMoreUsers()
                        }
                    }
                }
                
                if rankingBoardViewModel.isLoading {
                    ProgressView("Loading more...")
                        .padding()
                }
            }
            .padding(.top)
        }
    }
}

#Preview {
    RankingBoardView()
}
