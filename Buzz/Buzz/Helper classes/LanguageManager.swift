//
//  LanguageManager.swift
//  Buzz
//
//  Created by Jay Borania on 01/12/25.
//

import Foundation
import SwiftUI

@MainActor
final class LanguageManager: ObservableObject {
    @AppStorage("appLanguage") var appLanguage: String = "en" {
         didSet { applyLanguage() }
     }

     init() {
         let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
         appLanguage = saved
         applyLanguage()
     }

     func applyLanguage() {
         Bundle.overrideLanguage(appLanguage)
         objectWillChange.send()
     }

     /// Set language directly: "en", "de", "gu"
     func setLanguage(_ code: String) {
         appLanguage = code
     }
}
