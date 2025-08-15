//
//  SettingsView.swift
//  Buzz
//
//  Created by Harshil Gajjar on 04/08/25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    @StateObject private var settingsViewModel = SettingsViewModel()
    var body: some View {
        ZStack {
            VStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                HStack {
                    Button {
                        settingsViewModel.isLogoutSuccess.toggle()
                    } label: {
                        Text("Logout")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.orange.opacity(0.8) )
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical)
                }
                Spacer()
            }
            
            if settingsViewModel.isLoading {
                JBLoadingView()
            }
        }
        .alert("Logout", isPresented: $settingsViewModel.isLogoutSuccess) {
            Button("Logout", role: .destructive) {
                settingsViewModel.removeUserToken()
            }
            Button("No", role: .cancel) {
                print("User tapped No")
            }
        } message: {
            Text("Do you really want to logout?")
        }
        .onChange(of: settingsViewModel.fcmTokenRemoved) {
            if settingsViewModel.fcmTokenRemoved {
                Task {
                    let result = await userStateViewModel.signOut()
                    switch result {
                    case .success(_):
                        UserLoginCache.remove()
                    case .failure(_):
                        break
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
