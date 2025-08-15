//
//  UserModel.swift
//  Buzz
//
//  Created by Harshil Gajjar on 01/08/25.
//

import Foundation

struct User: Identifiable, Decodable, Hashable {
    var id: String
    var username: String
    var ranking: Int
    var gamePoints: Int
}

