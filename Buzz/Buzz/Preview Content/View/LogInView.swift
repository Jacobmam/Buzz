//
//  LogInView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 17.02.25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if verticalSizeClass == .compact {
                ScrollView {
                    loginContent
                }
            } else {
                loginContent
            }
        }
    }
    
    var loginContent: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image("3")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
            
            VStack(spacing: 15) {
                TextField("Email", text: $email)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            
            Button(action: {
                print("Sign Up pressed")
            }) {
                Text("SIGN UP")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
            }
            
            Button(action: {
                print("Create an account pressed")
            }) {
                Text("Create an account")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            .padding(.top, 10)
            
            Button(action: {
                print("Continue with Google pressed")
            }) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(.black)
                    Text("CONTINUE WITH GOOGLE")
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal, 30)
            }
            
            Spacer()
        }
    }
}

#Preview {
    LoginView()
}
