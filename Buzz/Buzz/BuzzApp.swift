//
//  BuzzApp.swift
//  Buzz
//
//  Created by Jacob Mampuya on 10.02.25.
//

import SwiftUI
import FirebaseCore

@main
struct BuzzApp: App {
    @StateObject private var viewModel = LoginViewModel()
    
    init() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            if viewModel.isLoggedIn {
                NavigatorView()
                    .environmentObject(viewModel)
            }
            else {
                LogoView()
                    .environmentObject(viewModel)
            }
        }
    }
}


