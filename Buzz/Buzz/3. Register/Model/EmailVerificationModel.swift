//
//  EmailVerificationModel.swift
//  Buzz
//
//  Created by Jay Borania on 20/08/25.
//

import Foundation

struct EmailVerificationModel {
    var email: String
    var otp: String
    var isEmailVerificationCodeSent: Bool = false
    var isEmailVerified: Bool = false
    var canResendVerificationCode: Bool = false
    var resendVerificationCodeLimit: Int = 3
    var resendVerificationCodeCountdown: Int = 60
    var isLoading: Bool = false
    var isUserRegistered: Bool = false
}
