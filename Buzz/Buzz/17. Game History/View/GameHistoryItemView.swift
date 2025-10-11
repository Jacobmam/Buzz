//
//  GameHistoryItemView.swift
//  Buzz
//
//  Created by Jay Borania on 11/10/25.
//

import SwiftUI

struct GameHistoryItemView: View {
    var gameHistory: GameHistoryModel
    var body: some View {
        HStack {
            // USER 1
            VStack {
                Circle()
                    .fill(.orange)
                    .frame(width: 50, height: 50)
            }
        }
    }
}

#Preview {
    GameHistoryItemView(gameHistory: GameHistoryModel(gameStartedAt: "10 Oct 2025",
                                                      gameEndedAt: "",
                                                      gameRequestId: "",
                                                      opponentScore: "111",
                                                      userScore: "222",
                                                      userId: "",
                                                      opponentId: "",
                                                      gameCompleted: true,
                                                      gameType: ""))
}
