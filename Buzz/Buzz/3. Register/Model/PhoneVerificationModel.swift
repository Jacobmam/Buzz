//
//  PhoneVerificationModel.swift
//  Buzz
//
//  Created by Jay Borania on 20/08/25.
//

import PhoneNumberKit
import Foundation

struct PhoneVerificationModel {
    var country: Country?
    var phoneNumber: String
    var phoneNumberPlain: String {
        guard let country else { return "" }
        let phoneNumberUtility = PhoneNumberUtility()
        let region = country.code
        if let parsedNumber = try? phoneNumberUtility.parse(phoneNumber, withRegion: region) {
            let e164 = phoneNumberUtility.format(parsedNumber, toType: .e164)
            return e164
        }
        return ""
    }
    var otp: String
    var isPhoneNumberVerificationCodeSent: Bool = false
    var canResendVerificationCode: Bool = false
    var resendVerificationCodeLimit: Int = 3
    var resendVerificationCodeCountdown: Int = 60
    var isPhoneNumberVerified: Bool = false
    var isLoading: Bool = false
}

struct Country: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let dial_code: String
    let code: String
    
    
    enum CodingKeys: String, CodingKey {
        case name
        case dial_code
        case code
    }
//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        name = try values.decodeIfPresent(String.self, forKey: .name)
//        dial_code = try values.decodeIfPresent(String.self, forKey: .dial_code)
//        code = try values.decodeIfPresent(String.self, forKey: .code)
//    }
}


