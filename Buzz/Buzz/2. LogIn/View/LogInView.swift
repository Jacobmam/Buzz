
//
//  LogInView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 17.02.25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var nav: NavigationManager
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        ZStack {
            if verticalSizeClass == .compact {
                ScrollView { loginContent }
            } else {
                ScrollView { loginContent }
            }
            if viewModel.isLoading {
                JBLoadingView()
            }
        }.alert(isPresented: $viewModel.showError) {
            Alert(title: Text(viewModel.errorTitle),
                  message: Text(viewModel.errorMessage),
                  dismissButton: .default(Text("OK"))
            )
        }
        .onChange(of: viewModel.userProfile, { oldValue, newValue in
            if let userProfile = viewModel.userProfile {
                Task {
                    UserLoginCache.save(userProfile)
                    let result = await userStateViewModel.signIn()
                    switch result {
                    case .success(_):
                        nav.reset()
                    case .failure(_):
                        break
                    }
                }
            }
        })
        .tint(.orange)
    }
    
    var loginContent: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image("applogo")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)
            
            VStack(spacing: 15) {
                TextField("Email/Username", text: $viewModel.email)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 0.5)
                    }
                
                SecureField("Password", text: $viewModel.password)
                    .padding()
                    .frame(height: 50)
                    .background(Color.white.opacity(0.2))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 0.5)
                    }
                    .cornerRadius(10)
            }
            .padding(.horizontal, 30)
            HStack {
                Spacer()
                Button {
                    nav.path.append(Route.forgotPasswordView)
                } label: {
                    Text("Forgot password")
                        .foregroundColor(.white)
                        .fontWeight(.light)
                }
                .padding(.horizontal,30)
                
            }
            Button(action: {
                viewModel.loginValidation()
            }) {
                Text("LOG IN")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .padding(.horizontal, 30)
            }
            
            Button {
                nav.path.append(Route.registerView)
            } label: {
                Text("Create an account")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
            }
            .padding(.top, 10)
            Spacer()
        }
    }
}

#Preview {
    LoginView()
    
}
