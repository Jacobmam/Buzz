//
//  SearchUserProfileView.swift
//  Buzz
//
//  Created by Jay Borania on 10/09/25.
//

import SwiftUI

struct SearchUserProfileView: View {
    @StateObject private var searchUserProfileViewModel = SearchUserProfileViewModel()
    @Environment(\.dismiss) var dismiss
    var searchedUser : User?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                profileHeader
                profileDetailsView
                gameData
                Spacer()
            }
        }
        .onAppear {
            searchUserProfileViewModel.id = searchedUser?.id ?? ""
            if searchUserProfileViewModel.id != "" {
                searchUserProfileViewModel.getGamePlayedCount()
            }
            searchUserProfileViewModel.getGameWinCount()
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
            
            Text("Player Profile")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
            
            Image(systemName: "message.fill")
                .resizable()
                .scaledToFit()
                .frame(height: 26)
                .foregroundColor(.orange)
            
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
    }
    
    var profileHeader: some View {
        VStack {
            HStack(spacing: 0) {
                // display profile image
                if let imageURL = searchedUser?.profilePic, imageURL.count > 0 {
                    AsyncImage(url: URL(string: imageURL),
                               scale: 1.0,
                               transaction: .init(animation: .spring())) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .tint(.orange)
                                .scaleEffect(1)
                                .transition(.opacity.combined(with: .scale))
                                .frame(width: 60, height: 60)
                                .padding(.trailing)
                            
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .transition(.opacity.combined(with: .scale))
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                                .padding(.trailing)
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
                        .frame(width: 60, height: 60)
                        .padding(.trailing)
                    
                }
                
                //                            Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text(searchedUser?.username ?? "")
                        .font(.system(size: 20, weight: .bold))
                    Text("\(searchedUser?.firstName ?? "") \(searchedUser?.lastName ?? "")")
                        .font(.system(size: 16, weight: .thin))
                }
                Spacer()
                
                if searchedUser?.basketballPosition != nil {
                    Text(searchedUser?.basketballPosition ?? "-")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        
                }
                
            }
            .padding()
            Divider()
                .background(Color.white)
                .padding(.vertical, 5)
            
            
        }
        .padding(.horizontal)
    }
    
    var profileDetailsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack {
                        Text("Ranking: ")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("#\(searchedUser?.ranking ?? 0)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.orange)
                        Spacer()
                        
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    )
                    
                    HStack {
                        Text("Points: ")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("\(searchedUser?.gamePoints ?? 0)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.orange)
                        Spacer()
                        
                    } .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                        )
                }
                
                HStack {
                    HStack {
                        Text("Game Played: ")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("\(searchUserProfileViewModel.gamePlayed)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.orange)
                        Spacer()
                        
                    }.padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                        )
                    
                    HStack {
                        Text("Game Wins: ")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        Text("\(searchUserProfileViewModel.gameWins)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.orange)
                        Spacer()
                        
                    }.padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemGray6))
                                .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                        )
                }
                
            }
            .padding()
            
            Spacer()
        }
    }
    
    var gameData: some View {
        VStack {
            Spacer()
            Text("Game data will be shown here.")
            Spacer()
        }
    }
}

#Preview {
    SearchUserProfileView(searchedUser: User.init(id: "1", username: "mborania", ranking: 7, gamePoints: 0, firstName: "Mansi", lastName: "Borania"))
}


