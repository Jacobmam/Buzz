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
    
    init() {
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            LogoView()
        }
    }
}


