//
//  NavigationManager.swift
//  Buzz
//
//  Created by Jay Borania on 12/08/25.
//

import Foundation
import SwiftUI

// MARK: - Routes for navigationDestination
enum Route: Hashable {
    case loginView
    case registerView
    case homeView
    case notificationsView
    case userSelectionView
    case gameModeView(opponentUser: User)
    case gameScoreboardView(requestId: String)
    case rankingBoardView
    case forgotPasswordView
    case editProfileView
    case searchUsersView
    case searchUserProfileView(searchedUser: User)
    case messageChatRoomView
    case messageConversationView(chatRoom: ChatRoomModel)
    case gameHistoryView
}

class NavigationManager: ObservableObject {
    @Published var path = NavigationPath()
    
    /// Clear the whole path (pop to root)
    func reset() {
        path = NavigationPath()
    }
    
    /// Convenience: pop to root keeping type-safe call
    func popToRoot() {
        if path.count > 0 { path.removeLast(path.count) }
    }
}
