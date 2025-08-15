//
//  AppCache.swift
//  Buzz
//
//  Created by Harshil Gajjar on 03/08/25.
//

import Foundation

struct UserLoginCache {
    static let key = "userLoginData"
    static func save(_ value: UserProfile) {
         UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: key)
    }
    static func get() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        return try? PropertyListDecoder().decode(UserProfile.self, from: data)
    }
    static func remove() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
