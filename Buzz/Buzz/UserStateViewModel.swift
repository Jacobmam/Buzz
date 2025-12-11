//
//  UserStateViewModel.swift
//  HandyBros
//
//  Created by Jay Borania on 29/05/24.
//

import SwiftUI
import Foundation

struct AppStorageKeys {
    static let isLoggedIn = "isLoggedIn"
    static let isFirstTimeAppOpen = "isFirstTimeAppOpen"
}

enum UserStateError: Error {
    case signInError, signOutError
}

@MainActor
class UserStateViewModel: ObservableObject {
    @EnvironmentObject private var nav: NavigationManager
    @AppStorage(AppStorageKeys.isLoggedIn) var isLoggedIn: Bool?
    @AppStorage(AppStorageKeys.isFirstTimeAppOpen) var isFirstTimeAppOpen: Bool = true
    @Published var isBusy = false
    @Published var canRedirect = false
    
    func signIn() async -> Result<Bool, UserStateError>  {
        isLoggedIn = true
        return .success(true)
    }
    
    func signOut() async -> Result<Bool, UserStateError>  {
        isLoggedIn = false
        return .success(true)
    }
}
