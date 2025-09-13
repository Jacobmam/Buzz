//
//  User.swift
//  Buzz
//
//  Created by Jacob Mampuya on 17.02.25.
//

import Foundation

struct UserProfile: Codable, Equatable, Identifiable {
    var id: String?
    var emailAddress: String?
    var username: String?
    var birthDate: String?
    var firstName: String?
    var lastName: String?
    var gender: String?
    var phoneNumber: String?
    var ranking: Int?
    var gamePoints: Int?
    var profilePic: String?
    var basketballPosition: String?
    var password : String?
    var isAccountDeleted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case emailAddress
        case username
        case birthDate
        case firstName
        case lastName
        case gender
        case phoneNumber
        case ranking
        case gamePoints
        case profilePic
        case basketballPosition
        case password
        case isAccountDeleted
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(String.self, forKey: .id)
        emailAddress = try values.decodeIfPresent(String.self, forKey: .emailAddress)
        username = try values.decodeIfPresent(String.self, forKey: .username)
        birthDate = try values.decodeIfPresent(String.self, forKey: .birthDate)
        firstName = try values.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try values.decodeIfPresent(String.self, forKey: .lastName)
        gender = try values.decodeIfPresent(String.self, forKey: .gender)
        phoneNumber = try values.decodeIfPresent(String.self, forKey: .phoneNumber)
        ranking = try values.decodeIfPresent(Int.self, forKey: .ranking)
        gamePoints = try values.decodeIfPresent(Int.self, forKey: .gamePoints)
        profilePic = try values.decodeIfPresent(String.self, forKey: .profilePic)
        basketballPosition = try values.decodeIfPresent(String.self, forKey: .basketballPosition)
        password = try values.decodeIfPresent(String.self, forKey: .password)
        isAccountDeleted = try values.decodeIfPresent(Bool.self, forKey: .isAccountDeleted)

    }
//    init(id: String, emailAddress: String, username: String, birthDate: String, firstName: String, lastName: String, gender: String, phoneNumber: String, ranking: Int = 0, gamePoints: Int = 0) {
//        self.id = id
//        self.emailAddress = emailAddress
//        self.username = username
//        self.birthDate = birthDate
//        self.firstName = firstName
//        self.lastName = lastName
//        self.gender = gender
//        self.phoneNumber = phoneNumber
//        self.ranking = ranking
//        self.gamePoints = gamePoints
//    }
    
//    func toDictionary() -> [String: Any] {
//           return [
//               "id": id,
//               "emailAddress": emailAddress,
//               "birthDate": birthDate,
//               "firstName": firstName,
//               "lastName": lastName,
//               "gender": gender,
//               "phoneNumber": phoneNumber,
//               "username": username,
//               "ranking": ranking,
//               "gamePoints": gamePoints
//           ]
//       }
}
