//
//  GameHistoryView.swift
//  Buzz
//
//  Created by Jay Borania on 25/09/25.
//

import SwiftUI

struct GameHistoryView: View {
    @StateObject private var gameHistoryViewModel = GameHistoryViewModel()
    @Environment(\.dismiss) var dismiss
    var body: some View {
        ZStack {
            VStack {
                headerView
                historyView
                Spacer()
            }
            if gameHistoryViewModel.isLoading {
                JBLoadingView()
            }
        }
        .onAppear {
            gameHistoryViewModel.fetchGameHistoryWithAllUsers()
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
            
            Text("Game History")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
    }
    
    
    var historyView: some View {
        ScrollView {
            if let userData = UserLoginCache.get() {
                ForEach($gameHistoryViewModel.allGameHistory, id: \.self) { $gameHistory in
                    VStack(alignment: .leading) {
                        HStack {
                            VStack {
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
                                    .font(Font.system(size: 16).bold())
                            }
                            Spacer()
                            VStack {
                                Text(gameHistory.gameType)
                                    .font(Font.system(size: 20).bold())
                                Text(gameHistoryViewModel.timeBetween(gameHistory.gameStartedAt, gameHistory.gameEndedAt) ?? "")
                                    .font(Font.system(size: 14).weight(.medium))
                            }
                            Spacer()
                            VStack {
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
                                    .font(Font.system(size: 16).bold())
                            }
                        }
                        .padding(10)
                        HStack(spacing: 0) {
                            Text(gameHistory.userScore)
                                .font(Font.system(size: 16).bold())
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .layoutPriority(1)
                            VStack {
                                Divider()
                                    .frame(height: 1)
                                    .background(.white)
                                    .foregroundColor(.white)
                            }
                            Text("Score")
                                .font(Font.system(size: 18).bold())
                                .padding(.horizontal, 5)
                            
                                .layoutPriority(1)
                            VStack {
                                Divider()
                                    .frame(height: 1)
                                    .background(.white)
                                    .foregroundColor(.white)
                            }
                            //                            Spacer()
                            Text(gameHistory.opponentScore)
                                .font(Font.system(size: 16).bold())
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .layoutPriority(1)
                        }
                        .padding(.horizontal)
                        .background(.orange.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        VStack(alignment: .leading) {
                            let winnerId = gameHistoryViewModel.getwinnerId(userScore: gameHistory.userScore, opponentScore: gameHistory.opponentScore, userId: gameHistory.userId, opponentId: gameHistory.opponentId)
                            
                            if winnerId == userData.id {
                                Text("\(gameHistoryViewModel.getPointsToBeDisplay(gameType: gameHistory.gameType)) hoop points earned")
                                    .font(Font.system(size: 14).weight(.bold))
                                    .foregroundColor(.green)
                            }
                            
                            Text("Played on \(gameHistoryViewModel.formatGameStartedAtDate(gameHistory.gameStartedAt) ?? "")")
                                .font(Font.system(size: 14).weight(.regular))
                            
                        }
                        .padding(.leading)
                        .padding(.top,10)
                    }
                    .padding()
                    .background(.orange.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
            }
        }
    }
}

struct RippleGlowAnimation: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // 🔁 Expanding ripple 1
            Circle()
                .stroke(Color.green.opacity(0.6), lineWidth: 3)
                .scaleEffect(animate ? 1.8 : 0.9)
                .opacity(animate ? 0 : 1)
                .animation(
                    Animation.easeOut(duration: 2).repeatForever(autoreverses: false),
                    value: animate
                )
            
            // 🔁 Expanding ripple 2 (delayed for wave effect)
            Circle()
                .stroke(Color.green.opacity(0.4), lineWidth: 2)
                .scaleEffect(animate ? 2.3 : 1.0)
                .opacity(animate ? 0 : 1)
                .animation(
                    Animation.easeOut(duration: 2).delay(0.5).repeatForever(autoreverses: false),
                    value: animate
                )
            
            // 🌟 Soft glowing circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.green.opacity(0.6), .clear]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 40
                    )
                )
                .scaleEffect(animate ? 1.05 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: animate
                )
        }
        .onAppear {
            animate = true
        }
    }
}


#Preview {
    GameHistoryView()
}

