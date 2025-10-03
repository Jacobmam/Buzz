
//
//  Untitled.swift
//  Buzz
//
//  Created by Harshil Gajjar on 04/08/25.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
//    @Published var username : String = ""
//    @Published var firstName : String = ""
//    @Published var lastName : String = ""
//    @Published var ranking: Int = 0
//    @Published var gamePoints : Int = 0
//    @Published var profilePic : String?
    @Published var isLoading: Bool = false
    
    init(){}
    
}
