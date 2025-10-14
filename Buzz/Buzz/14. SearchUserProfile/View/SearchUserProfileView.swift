//
//  SearchUserProfileView.swift
//  Buzz
//
//  Created by Jay Borania on 10/09/25.
//

import SwiftUI

struct SearchUserProfileView: View {
    @EnvironmentObject private var nav: NavigationManager
    @EnvironmentObject private var firebaseMessagesHelper: FirebaseMessagesHelper
    @StateObject private var searchUserProfileViewModel = SearchUserProfileViewModel()
    @Environment(\.dismiss) var dismiss
    var searchedUser : User?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                headerView
                profileHeader
                profileDetailsView
                Divider()
                    .background(Color.white)
                    .padding( )
                historyView
                Spacer()
            }
            if firebaseMessagesHelper.isLoading {
                JBLoadingView()
            }
        }
        .onAppear {
            searchUserProfileViewModel.userData = UserLoginCache.get()
            if let searchedUserId = searchedUser?.id, let userId = searchUserProfileViewModel.userData?.id {
                searchUserProfileViewModel.getGamePlayedCount(searchedUserId: searchedUserId)
                searchUserProfileViewModel.getGameWinCount(searchedUserId: searchedUserId)
                searchUserProfileViewModel.fetchGameHistoryWithSearchedUser(userID: userId, searchedUserId: searchedUserId)
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
            
            Text("Player Profile")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
            Button {
                if let searchedUserId = searchedUser?.id, let myId = UserLoginCache.get()?.id {
                    firebaseMessagesHelper.fetchOrCreateDirectChat(with: searchedUserId, currentUserId: myId) { room in
                        if let room { nav.path.append(Route.messageConversationView(chatRoom: room)) }
                    }
                }
            } label: {
                Image(systemName: "message.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 26)
                    .foregroundColor(.orange)
            }
            
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
    }
    
    var profileHeader: some View {
        VStack {
            HStack(spacing: 0) {
                // display profile image
                //                if let imageURL = searchedUser?.profilePic, imageURL.count > 0 {
                //                    AsyncImage(url: URL(string: imageURL),
                //                               scale: 1.0,
                //                               transaction: .init(animation: .spring())) { phase in
                //                        switch phase {
                //                        case .empty:
                //                            ProgressView()
                //                                .tint(.orange)
                //                                .scaleEffect(1)
                //                                .transition(.opacity.combined(with: .scale))
                //                                .frame(width: 60, height: 60)
                //                                .padding(.trailing)
                //
                //                        case .success(let image):
                //                            image
                //                                .resizable()
                //                                .scaledToFill()
                //                                .transition(.opacity.combined(with: .scale))
                //                                .frame(width: 60, height: 60)
                //                                .clipShape(Circle())
                //                                .padding(.trailing)
                //                                .id(imageURL)
                //                        case .failure(_):
                //                            Color.white.opacity(0.1)
                //                        @unknown default:
                //                            Color.white.opacity(0.2)
                //                        }
                //                    }
                //                               .scaledToFill()
                //
                //                } else {
                //                    Image(systemName: "person.circle.fill")
                //                        .resizable()
                //                        .foregroundColor(.orange)
                //                        .tint(.orange)
                //                        .scaledToFill()
                //                        .frame(width: 60, height: 60)
                //                        .padding(.trailing)
                //
                //                }
                HStack {
                    if let imgURL = URL(string: searchedUser?.profilePic ?? "") {
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
                .frame(width: 60, height: 60)
                .padding(.trailing)
                
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
    var historyView: some View {
        VStack {
            if let userData = UserLoginCache.get() {
                if searchUserProfileViewModel.allGameHistory.count == 0 && !searchUserProfileViewModel.isLoading {
                    VStack {
                        Spacer()
                        Text("No game played with this player yet.")
                        Spacer()
                    }
                } else {
                    ScrollView {
                        ForEach(searchUserProfileViewModel.allGameHistory, id: \.self) { gameHistory in
                            ZStack {
                                let winnerId = searchUserProfileViewModel.getwinnerId(userScore: gameHistory.userScore, opponentScore: gameHistory.opponentScore, userId: gameHistory.userId, opponentId: gameHistory.opponentId)
                                VStack {
                                    VStack {
                                        HStack {
                                            VStack(spacing: 0) {
                                                ZStack {
                                                    if  gameHistory.userScore > gameHistory.opponentScore {
                                                        RippleGlowAnimation()
                                                            .frame(width: 50, height: 50)
                                                    }
                                                    HStack {
                                                        if let imgURL = URL(string: gameHistory.user?.profilePic ?? "") {
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
                                                    .frame(width: 50, height: 50)
                                                    
                                                    if gameHistory.userScore > gameHistory.opponentScore {
                                                        Image("winner_crown")
                                                            .resizable()
                                                            .frame(width:20, height: 20)
                                                            .scaledToFill()
                                                            .offset(x: 20, y: -20)
                                                    }
                                                }
                                                
                                                
                                                Text(gameHistory.user?.username ?? "")
                                                    .font(.system(size: 16).bold())
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                                
                                            }
                                            Spacer()
                                            VStack {
                                                Text(gameHistory.gameType)
                                                    .font(.system(size: 25).bold())
                                                    .layoutPriority(1)
                                                Text(searchUserProfileViewModel.timeBetween(gameHistory.gameStartedAt, gameHistory.gameEndedAt) ?? "")
                                                    .font(.system(size: 12).weight(.regular))
                                                    .layoutPriority(1)
                                                
                                            }
                                            Spacer()
                                            VStack(spacing: 0) {
                                                ZStack {
                                                    if  gameHistory.userScore < gameHistory.opponentScore {
                                                        RippleGlowAnimation()
                                                            .frame(width: 50, height: 50)
                                                    }
                                                    HStack {
                                                        if let imgURL = URL(string: gameHistory.opponent?.profilePic ?? "") {
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
                                                    .frame(width: 50, height: 50)
                                                    if gameHistory.userScore < gameHistory.opponentScore {
                                                        Image("winner_crown")
                                                            .resizable()
                                                            .frame(width:20, height: 20)
                                                            .scaledToFill()
                                                            .offset(x: 20, y: -20)
                                                    }
                                                }
                                                Text(gameHistory.opponent?.username ?? "")
                                                    .font(.system(size: 16).bold())
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                            }
                                        }
                                    }
                                    .padding(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        Color.orange.opacity(0.8),
                                                        Color.orange.opacity(0.5),
                                                        Color.orange.opacity(0.2),
                                                        Color.orange.opacity(0.05)
                                                    ]),
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                ),
                                                lineWidth: 1.5
                                            )
                                    )
                                    
                                    VStack(alignment: .leading) {
                                        
                                        HStack {
                                            if winnerId == userData.id {
                                                Text("\(searchUserProfileViewModel.getPointsToBeDisplay(gameType: gameHistory.gameType)) hoop points earned")
                                                    .font(Font.system(size: 14).weight(.bold))
                                                    .foregroundColor(.green.opacity(0.7))
                                            }
                                            Spacer()
                                        }
                                    }
                                    .padding(.leading)
                                    .padding(.top,10)
                                    
                                } .padding(20)
                                    .background(.orange.opacity(0.2))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .padding()
                                
                                
                                Text(searchUserProfileViewModel.formatGameStartedAtDate(gameHistory.gameStartedAt) ?? "")
                                    .font(.system(size: 16).weight(.semibold))
                                    .padding(5)
                                    .background(Color(UIColor(red: 0.20, green: 0.11, blue: 0.04, alpha: 1.0)))
                                    .padding(.horizontal)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .offset(x: 0, y:winnerId == userData.id ? -84 : -73)
                                //                            .layoutPriority(1)
                                HStack(spacing: 0) {
                                    Spacer()
                                    Text("Score")
                                        .font(Font.system(size: 16).weight(.light))
                                    
                                        .padding(.horizontal, 5)
                                        .background(Color(UIColor(red: 0.20, green: 0.11, blue: 0.04, alpha: 1.0)))
                                    
                                        .layoutPriority(1)
                                    Spacer()
                                }
                                
                                .padding(.horizontal)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .offset(x: 0, y:winnerId == userData.id ? 50 : 58)
                                HStack(spacing: 30) {
                                    
                                    Text(gameHistory.userScore)
                                        .font(Font.system(size: 16).weight(.bold))
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 5)
                                        .background(Color(UIColor(red: 0.20, green: 0.11, blue: 0.04, alpha: 1.0)))
                                        .padding(.horizontal, 40)
                                        .layoutPriority(1)
                                    
                                    Spacer()
                                    Text(gameHistory.opponentScore)
                                        .font(Font.system(size: 16).weight(.bold))
                                        .foregroundColor(.orange)
                                        .padding(.horizontal, 5)
                                        .background(Color(UIColor(red: 0.20, green: 0.11, blue: 0.04, alpha: 1.0)))
                                        .padding(.horizontal, 40)
                                        .layoutPriority(1)
                                    
                                }
                                .padding(.horizontal)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .offset(x: 0, y: winnerId == userData.id ? 50 : 58)
                            }
                        }
                    }
                }
            }
        }
    }
    
}

#Preview {
    SearchUserProfileView(searchedUser: User.init(id: "1", username: "mborania", ranking: 7, gamePoints: 0, firstName: "Mansi", lastName: "Borania"))
}


