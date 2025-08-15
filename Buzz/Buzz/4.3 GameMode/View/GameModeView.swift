//
//  GameModeView.swift
//  Buzz
//
//  Created by Harshil Gajjar on 01/08/25.
//

import SwiftUI

struct GameModeView: View {
    var opponentUser: User?
    @EnvironmentObject private var nav: NavigationManager
    @StateObject private var gameModeViewModel = GameModeViewModel()
    @Environment(\.dismiss) private var dismiss
    private let gameModes = ["1v1", "3v3", "5v5"]
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                
                Text("Choose game with \(opponentUser?.username ?? "-")")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 2)
                
                // Looping through the array to create buttons dynamically
                ForEach(gameModes, id: \.self) { mode in
                    Button {
                        print("Button pressed: \(mode)")
                        gameModeViewModel.selectGameMode(mode)
                        // In future, you can add navigation logic here if needed
                    } label: {
                        HStack {
                            Text(mode)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: (gameModeViewModel.selectedMode == mode) ? "checkmark.square.fill" : "square")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.white)
                                .frame(height: 22)
                        }
                        .padding()
                        .background((gameModeViewModel.selectedMode == mode) ? .orange : .clear)
                        .cornerRadius(10)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                                .fill(.white)
                        }
                    }
                    .padding(.horizontal, 30)
                }
                
                Spacer()
            }
            
        }
        .alert(isPresented: $gameModeViewModel.requestFailed) {
            Alert(
                title: Text("Error"),
                message: Text(gameModeViewModel.errorMessage),
                dismissButton: .default(Text("OK")) {
                    
                }
            )
        }
        .alert(isPresented: $gameModeViewModel.requestSuccess) {
            Alert(
                title: Text("Success"),
                message: Text(gameModeViewModel.errorMessage),
                dismissButton: .default(Text("OK")) {
                    nav.path.append(Route.gameScoreboardView(requestId: gameModeViewModel.requestId))
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
            
            Text("Select Mode")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
            
            Button {
                if let opponentUser {
                    gameModeViewModel.sendGameRequest(opponentUser: opponentUser)
                }
            } label: {
                Text("SEND")
                    .bold()
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                    .foregroundStyle(.white)
            }
            .background(.orange)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(gameModeViewModel.selectedMode == nil)
            .opacity(gameModeViewModel.selectedMode == nil ? 0.5 : 1.0)
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
    }
}

#Preview {
    GameModeView(opponentUser: User(id: "1", username: "Test", ranking: 1, gamePoints: 1))
}
