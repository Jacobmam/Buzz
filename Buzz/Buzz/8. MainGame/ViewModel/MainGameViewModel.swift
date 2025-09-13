//
//  MainGameViewModel.swift
//  Buzz
//
//  Created by Harshil Gajjar on 02/08/25.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    // Assuming we have a user profile and the selected mode
    @Published var currentUser: User
    @Published var opponentUsername: String
    @Published var selectedMode: String
    
    init(currentUser: User, opponentUsername: String, selectedMode: String) {
        self.currentUser = currentUser
        self.opponentUsername = opponentUsername
        self.selectedMode = selectedMode
    }
    
    // Function to update opponent
    func updateOpponent(username: String) {
        self.opponentUsername = username
    }
    
    // Function to update selected mode
    func updateSelectedMode(mode: String) {
        self.selectedMode = mode
    }
}

