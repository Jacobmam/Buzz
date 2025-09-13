//
//  EmailVerificationView.swift
//  Buzz
//
//  Created by Jay Borania on 18/08/25.
//

import SwiftUI

struct EmailVerificationView: View {
    @Binding var emailVerification: EmailVerificationModel
    var onTapVerifyEmail: () -> Void
    var onTapVerifyEmailOTP: () -> Void
    @State var otpTimer: Timer!
    
    func startResendOTPTimer() {
        guard emailVerification.resendVerificationCodeLimit > 0 else { return }
        emailVerification.resendVerificationCodeLimit -= 1
        emailVerification.resendVerificationCodeCountdown = 60
        otpTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            if self.emailVerification.resendVerificationCodeCountdown > 0 {
                self.emailVerification.resendVerificationCodeCountdown -= 1
            } else {
                self.otpTimer.invalidate()
            }
        })
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    TextField("Email Address", text: $emailVerification.email)
                        .padding()
                        .frame(height: 50)
                        .background(emailVerification.isEmailVerified || emailVerification.resendVerificationCodeLimit <= 0 || emailVerification.isEmailVerificationCodeSent ? .clear : Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: emailVerification.isEmailVerified ? 0 : 0.5)
                        }
                        .disabled(emailVerification.isEmailVerified )
                        .disabled(emailVerification.isEmailVerificationCodeSent)
                        .disabled(emailVerification.resendVerificationCodeLimit <= 0)
                    
                    if !emailVerification.isEmailVerificationCodeSent &&
                        !emailVerification.isEmailVerified {
                        Button {
                            HelperClass.shared.endEditing()
                            onTapVerifyEmail()
                            //                        startResendOTPTimer()
                        } label: {
                            Text("VERIFY")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .padding()
                        }
                        .frame(height: 50)
                        .background(.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    if emailVerification.isEmailVerified {
                        HStack {
                            Image(systemName: "checkmark.seal")
                            Text("Verified")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundStyle(.green)
                        .padding(.horizontal)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: emailVerification.isEmailVerified ? 0.5 : 0)
                }
                
                if emailVerification.isEmailVerificationCodeSent &&
                    !emailVerification.isEmailVerified  {
                    VStack {
                        if emailVerification.resendVerificationCodeLimit > 0 {
                            HStack {
                                TextField("OTP", text: $emailVerification.otp)
                                    .padding()
                                    .frame(height: 50)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(10)
                                    .autocapitalization(.none)
                                    .keyboardType(.numberPad)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(lineWidth: 0.5)
                                    }
                                
                                Button {
                                    HelperClass.shared.endEditing()
                                    onTapVerifyEmailOTP()
                                } label: {
                                    Text("Verify")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding()
                                }
                                .frame(height: 50)
                                .background(.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                        
                        HStack {
                            if emailVerification.resendVerificationCodeLimit == 0 {
                                Text("You have exceeded the maximum number of attempts to resend the OTP. Please try again later.")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(.white)
                                    .padding()
                                Spacer()
                            }
                            if emailVerification.resendVerificationCodeCountdown > 0 && emailVerification.resendVerificationCodeLimit > 0 {
                                Text("Resend in \(emailVerification.resendVerificationCodeCountdown) seconds")
                                    .font(.system(size: 13, weight: .thin))
                                    .foregroundStyle(.white)
                                    .padding()
                                Spacer()
                            } else if emailVerification.resendVerificationCodeLimit > 0 {
                                Button {
                                    emailVerification.otp = ""
                                    emailVerification.isEmailVerificationCodeSent = false
                                    onTapVerifyEmail()
                                } label: {
                                    Text("Resend")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(emailVerification.resendVerificationCodeCountdown > 0 ? .orange.opacity(0.5) : .orange)
                                        .padding()
                                }
                                .frame(height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                Spacer()
                            }
                        }
                    }
                }
//                Spacer()
            }
        }
       
        .onChange(of: emailVerification.isEmailVerificationCodeSent) {
            if emailVerification.isEmailVerificationCodeSent {
                startResendOTPTimer()
            }
        }
    }
}

#Preview {
    EmailVerificationView(emailVerification: .constant(.init(email: "", otp: "")),
                          onTapVerifyEmail: { },
                          onTapVerifyEmailOTP: { })
}
