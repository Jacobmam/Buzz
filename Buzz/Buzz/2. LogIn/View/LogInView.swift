
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
        //        NavigationStack {
        ZStack {
            if verticalSizeClass == .compact {
                ScrollView { loginContent }
            } else {
                loginContent
            }
            
            if viewModel.isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView()
            }
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.loginError != nil },
            set: { if !$0 { viewModel.loginError = nil } }
        )) {
            Alert(title: Text("Fehler"), message: Text(viewModel.loginError ?? ""), dismissButton: .default(Text("OK")))
        }
        .onChange(of: viewModel.userProfile, { oldValue, newValue in
            if let userProfile = viewModel.userProfile {
                Task {
                    UserLoginCache.save(userProfile)
                    let result = await userStateViewModel.signIn()
                    switch result {
                    case .success(let success):
                        nav.reset()
                    case .failure(let failure):
                        break
                    }
                }
            }
        })
        //        }
        .tint(.orange)
    }

    var loginContent: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image("3")
                .resizable()
                .scaledToFit()
                .frame(width: 400, height: 400)

            VStack(spacing: 15) {
                TextField("Email", text: $viewModel.email)
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

            Button(action: {
                viewModel.loginWithEmail()
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
