//
//  ForgotPasswordView.swift
//  Buzz
//
//  Created by Jay Borania on 04/09/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var forgotPasswordViewModel = ForgotPasswordViewModel()
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 20) {
                headerView
                emailVerificationView
                    .padding(.horizontal, 30)
                Spacer()
            }
            if forgotPasswordViewModel.isLoading {
                JBLoadingView()
            }
            if forgotPasswordViewModel.emailVerification.isLoading {
                JBLoadingView()
            }
        } .alert(isPresented: $forgotPasswordViewModel.showError) {
            Alert(
                title: Text(forgotPasswordViewModel.errorTitle),
                message: Text(forgotPasswordViewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    if forgotPasswordViewModel.errorTitle == "Password Updated" {
                        dismiss()
                    }
                }
            )
        }
    }
    var headerView: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .tint(.orange)
                    .frame(height: 20)
                    .bold()
            }
            .frame(width: 50, height: 50)
            
            Text("Forgot Password")
                .fontWeight(.bold)
                .foregroundColor(.orange)
                .font(.system(size: 20))
            
            Spacer()
        }
        .padding(.leading, 10)
        .padding(.trailing, 30)
    }
    
    var emailVerificationView: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text(forgotPasswordViewModel.emailVerification.isEmailVerified ? "Choose a new password" : "Hey, What's your registered email ?")
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.leading)
                if !forgotPasswordViewModel.emailVerification.isEmailVerified {
                    EmailVerificationView(emailVerification: $forgotPasswordViewModel.emailVerification,
                                          onTapVerifyEmail: {
                        forgotPasswordViewModel.sendForgotPasswordEmailOtp(email: forgotPasswordViewModel.emailVerification.email) { success, message in
                            DispatchQueue.main.async {
                                forgotPasswordViewModel.emailVerification.isEmailVerificationCodeSent = success
                                if success == false && message == "" {
                                    forgotPasswordViewModel.errorTitle = "Email not found"
                                    forgotPasswordViewModel.errorMessage = "Please use your registered email."
                                    forgotPasswordViewModel.showError = true
                                }
                            }
                        }
                    },
                                          onTapVerifyEmailOTP: {
                        forgotPasswordViewModel.verifyForgotPasswordEmailOtp(email: forgotPasswordViewModel.emailVerification.email,
                                                                             otp: forgotPasswordViewModel.emailVerification.otp) {  success, message, recordId in
                            DispatchQueue.main.async {
                                forgotPasswordViewModel.emailVerification.isEmailVerified = success
                                forgotPasswordViewModel.recordId  = recordId ?? ""
                            }
                        }
                    })
                }
                if forgotPasswordViewModel.emailVerification.isEmailVerified {
                    choosePasswordView
                }
            }
        }
    }
    
    var choosePasswordView: some View {
        ZStack {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    TextField("Choose New Password", text: $forgotPasswordViewModel.password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                    
                    TextField("Confirm Password", text: $forgotPasswordViewModel.confirmPassword)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(lineWidth: 0.5)
                        }
                        .cornerRadius(10)
                    
                    Text("Password should be atleast 8 characters long!")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(.yellow)
                        .padding(.horizontal)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                        .layoutPriority(1)
                }
                .padding(.vertical)
                
                HStack {
                    Spacer()
                    Button {
                        HelperClass.shared.endEditing()
                        let (isValid, message) = HelperClass.shared.validatePassword(password: forgotPasswordViewModel.password, confirmPassword: forgotPasswordViewModel.confirmPassword)
                        if isValid {
                            forgotPasswordViewModel.updatePassword()
                        } else {
                            forgotPasswordViewModel.errorTitle = "Error"
                            forgotPasswordViewModel.errorMessage = message
                            forgotPasswordViewModel.showError = true
                        }
                    } label: {
                        Text("LET'S GO")
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .heavy))
                            .padding()
                    }
                    .background(.orange)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        
        .alert(isPresented: $forgotPasswordViewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(forgotPasswordViewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    
                }
            )
        }
    }
    
}
#Preview {
    ForgotPasswordView()
}
