//
//  GameScoreboardView.swift
//  Buzz
//
//  Created by Harshil Gajjar on 03/08/25.
//

import SwiftUI

struct GameScoreboardView: View {
    @EnvironmentObject private var nav: NavigationManager
    @StateObject private var gameScoreboardViewModel = GameScoreboardViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var requestId: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                basicGameDetailsView
                
                Spacer()
                Spacer()
            }
            .padding()
        }
        .toolbarVisibility(.hidden, for: .tabBar)
        .onAppear {
            gameScoreboardViewModel.fetchGameRequestData(requestId)
        }
        .alert(isPresented: $gameScoreboardViewModel.showRequestCancelResponseAlert) {
            Alert(
                title: Text("Success"),
                message: Text("You have cancelled the request."),
                dismissButton: .default(Text("OK")) {
                    nav.reset()
                }
            )
        }
    }
    
    var waitingForOpponentView: some View {
        VStack {
            Spacer()
            
            ProgressView()
            Text("Waiting for \(gameScoreboardViewModel.gameRequestData?.opponentName ?? "opponent") to accept the request")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            HStack {
                Button {
                    gameScoreboardViewModel.updateRequestStatus(.cancelled, requestId: requestId)
                } label: {
                    Text("Cancel Request")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.red)
                .cornerRadius(12)
                .padding()
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    var basicGameDetailsView: some View {
        VStack(spacing: 20) {
            if gameScoreboardViewModel.gameRequestData?.gameRequestStatus == .accepted &&
                gameScoreboardViewModel.gameHistoryData?.gameCompleted != true {
                timerStarStopButtonView
            }
            
            HStack {
                playerAndGameInfoView
                Spacer()
                timerView
            }
            .padding(.horizontal)
            
            gradientSeparator
            
            switch gameScoreboardViewModel.gameRequestData?.gameRequestStatus {
            case .pending:
                waitingForOpponentView
            case .accepted:
                if gameScoreboardViewModel.gameHistoryData?.gameCompleted == true {
                    enterScoreView
                } else if !(gameScoreboardViewModel.gameHistoryData?.gameEndedAt ?? "").isEmpty &&
                            !(gameScoreboardViewModel.gameHistoryData?.gameCompleted ?? true) {
                    endGameButtonView
                }
            case .completed:
                enterScoreView
            default:
                EmptyView()
            }
        }
    }
    
    var gradientSeparator: some View {
        Image("gradient_img")
            .resizable()
            .frame(height: 4)
    }
    
    var playerAndGameInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(gameScoreboardViewModel.gameRequestData?.gameType ?? "-")
                .bold()
                .foregroundColor(.white)
                .font(.system(size: 16))
                .padding(.horizontal, 8)
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 30))
            
            if let userData = UserLoginCache.get() {
                let myName = (userData.id == gameScoreboardViewModel.gameRequestData?.userId) ? gameScoreboardViewModel.gameRequestData?.userName ?? "You" : gameScoreboardViewModel.gameRequestData?.opponentName ?? "Opponent"
                
                let opponentName = (userData.id == gameScoreboardViewModel.gameRequestData?.userId) ? gameScoreboardViewModel.gameRequestData?.opponentName ?? "Opponent" : gameScoreboardViewModel.gameRequestData?.userName ?? "You"
                
                Text(myName)
                    .bold()
                    .foregroundColor(.white)
                    .font(.system(size: 26))
                +
                Text(" vs ")
                    .foregroundColor(.orange)
                    .font(.system(size: 22))
                +
                Text(opponentName)
                    .bold()
                    .foregroundColor(.white)
                    .font(.system(size: 26))
            }
        }
    }
    
//    var waitingView: some View {
//        VStack {
//            ProgressView()
//            Text("Waiting for \(gameScoreboardViewModel.gameRequestData?.opponentName ?? "opponent") to accept the request")
//                .font(.system(size: 20, weight: .bold))
//                .foregroundColor(.white)
//                .multilineTextAlignment(.center)
//        }
//    }
    
    var timerStarStopButtonView: some View {
        Button {
            if (gameScoreboardViewModel.gameHistoryData?.gameStartedAt ?? "").isEmpty {
                // START GAME
                gameScoreboardViewModel.updateGameStartTimeInHistory()
            } else {
                // STOP GAME
                gameScoreboardViewModel.updateGameEndTimeInHistory()
            }
        } label: {
            VStack {
                Image(systemName: "timer")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 34)
                    .foregroundStyle(.orange)
                
                Text((gameScoreboardViewModel.gameHistoryData?.gameStartedAt ?? "").isEmpty ? "START" : "STOP")
                    .bold()
                    .foregroundColor(.orange)
                    .font(.system(size: 24))
            }
        }
        .padding(30)
        .overlay {
            Circle()
                .stroke(lineWidth: 2)
                .fill(.orange)
        }
    }
    
    var timerView: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text("Timer")
                .bold()
                .foregroundColor(.white)
                .font(.system(size: 16))
                .padding(.horizontal, 8)
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Text(gameScoreboardViewModel.timerString)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.orange)
        }
    }
    
    var endGameButtonView: some View {
        HStack {
            Text("End game to enter score.")
                .italic()
                .fontWeight(.light)
                .foregroundColor(.white)
                .font(.system(size: 12))
            
            Spacer()
            
            Button {
                gameScoreboardViewModel.updateGameCompletedFlagInHistory()
            } label: {
                Text("END GAME")
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .font(.system(size: 16))
            }
            .padding()
            .background(.orange)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 0.5)
                .foregroundStyle(.orange)
        }
    }
    
    var enterScoreView: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    
                    if let userData = UserLoginCache.get() {
                        let myName = (userData.id == gameScoreboardViewModel.gameRequestData?.userId) ? gameScoreboardViewModel.gameRequestData?.userName ?? "You" : gameScoreboardViewModel.gameRequestData?.opponentName ?? "Opponent"
                        
                        Text(myName)
                            .bold()
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                        
                        TextField("XXX", text: $gameScoreboardViewModel.txtMyScore)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(((gameScoreboardViewModel.gameHistoryData?.gameCompleted ?? false) && gameScoreboardViewModel.whatIsMyResult() != "") ? .clear : Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disabled((gameScoreboardViewModel.gameHistoryData?.gameCompleted ?? false) && gameScoreboardViewModel.whatIsMyResult() != "")
                    }
                }
                
                VStack(alignment: .leading) {
                    if let userData = UserLoginCache.get() {
                        let opponentName = (userData.id == gameScoreboardViewModel.gameRequestData?.userId) ? gameScoreboardViewModel.gameRequestData?.opponentName ?? "Opponent" : gameScoreboardViewModel.gameRequestData?.userName ?? "You"
                        
                        Text(opponentName)
                            .bold()
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                        
                        TextField("XXX", text: $gameScoreboardViewModel.txtOpponentScore)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(((gameScoreboardViewModel.gameHistoryData?.gameCompleted ?? false) && gameScoreboardViewModel.whatIsMyResult() != "") ? .clear : Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disabled((gameScoreboardViewModel.gameHistoryData?.gameCompleted ?? false) && gameScoreboardViewModel.whatIsMyResult() != "")
                    }
                }
            }
            
            if gameScoreboardViewModel.gameHistoryData?.gameCompleted == true &&
                gameScoreboardViewModel.whatIsMyResult() != "" {
                gradientSeparator
                    .padding(.bottom, 20)
                resultView
            } else {
                Button {
                    gameScoreboardViewModel.updateGameScores(requestId)
                } label: {
                    Text("SAVE SCORE")
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(.orange)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled((gameScoreboardViewModel.txtMyScore.isEmpty && gameScoreboardViewModel.txtOpponentScore.isEmpty))
                .opacity((gameScoreboardViewModel.txtMyScore.isEmpty && gameScoreboardViewModel.txtOpponentScore.isEmpty) ? 0.5 : 1.0)
            }
        }
    }
    
    @ViewBuilder
    var resultView: some View {
        VStack {
            Spacer()
            let result = gameScoreboardViewModel.whatIsMyResult()
            switch result {
            case "win":
                VStack {
                    Text("You won this game !")
                        .fontWeight(.heavy)
                        .foregroundColor(.green)
                        .font(.system(size: 26))
                        .frame(maxWidth: .infinity)
                    
                    Text("Congratulations 🎊🎉")
                        .bold()
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                    
                    Text("You have earned")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                    
                    Text("\(gameScoreboardViewModel.getPointsToBeAdded())")
                        .bold()
                        .foregroundColor(.orange)
                        .font(.system(size: 42))
                    
                    Text("Game Points")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                    
                }
            case "lose":
                Text("You lose this game !")
                    .fontWeight(.heavy)
                    .foregroundColor(.red)
                    .font(.system(size: 26))
                    .frame(maxWidth: .infinity)
            case "tie":
                Text("This is tie !")
                    .fontWeight(.heavy)
                    .foregroundColor(.white)
                    .font(.system(size: 26))
                    .frame(maxWidth: .infinity)
            default:
                Text("Something went wrong !")
                    .fontWeight(.heavy)
                    .foregroundColor(.red)
                    .font(.system(size: 26))
                    .frame(maxWidth: .infinity)
            }
            
            Spacer()
            backToHomeButtonView
        }
    }
    
    var backToHomeButtonView: some View {
        Button {
            nav.reset()
        } label: {
            Text("Back To Home")
                .fontWeight(.heavy)
                .foregroundColor(.white)
                .font(.system(size: 26))
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(.orange)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    GameScoreboardView(requestId: "04FD624C-90AA-4BA5-A5E6-4E697D6F01ED")
}
