//
//  BuzzApp.swift
//  Buzz
//
//  Created by Jacob Mampuya on 10.02.25.
//

import SwiftUI

@main
struct BuzzApp: App {
    @StateObject var languageManager = LanguageManager()
    @StateObject var userStateViewModel = UserStateViewModel()
    @StateObject var nav = NavigationManager()
    @StateObject var firebaseMessagesHelper = FirebaseMessagesHelper()
    @StateObject var firebaseCommonClass = FirebaseCommonClass()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        Bundle.overrideLanguage(saved)
    }
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(userStateViewModel)
                .environmentObject(nav)
                .environmentObject(firebaseMessagesHelper)
                .environmentObject(firebaseCommonClass)
                .environmentObject(appDelegate)
                .environmentObject(languageManager)
                .environment(\.locale, Locale(identifier: languageManager.appLanguage))
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

