//
//  BuzzApp.swift
//  Buzz
//
//  Created by Jacob Mampuya on 10.02.25.
//

import SwiftUI

@main
struct BuzzApp: App {
    
    @StateObject var userStateViewModel = UserStateViewModel()
    @StateObject var nav = NavigationManager()
    @StateObject var firebaseMessagesHelper = FirebaseMessagesHelper()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(userStateViewModel)
                .environmentObject(nav)
                .environmentObject(firebaseMessagesHelper)
                .environmentObject(appDelegate)
//            if userStateViewModel.isLoggedIn {
//                NavigatorView()
//                    .environmentObject(userStateViewModel)
//            }
//            else {
//                SplashView()
//                    .environmentObject(userStateViewModel)
//            }
        }
    }
}



