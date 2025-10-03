//
//  SettingsView.swift
//  Buzz
//
//  Created by Harshil Gajjar on 04/08/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    @StateObject private var profileViewModel = ProfileViewModel()
    @EnvironmentObject private var nav: NavigationManager
    @EnvironmentObject private var firebaseMessagesHelper: FirebaseMessagesHelper
    @State private var showPhotoPicker = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    headerView
                    userProfileView
                    
                    Divider()
                    userRankAndPointView
                    Divider()
                    
                    extraOptionsView
                    Divider()
                    
                    Spacer()
                    logoutAndDeleteAccountButtonView
                }
                
            }
            if profileViewModel.isLoading {
                JBLoadingView()
            }
        }
        .alert(isPresented: $profileViewModel.showError) {
            Alert(
                title: Text(profileViewModel.errorTitle),
                message: Text(profileViewModel.errorMessage),
                dismissButton: .default(Text("OK")) {
                    if profileViewModel.errorTitle == "Success" {
                        dismiss()
                    }
                }
            )
        }
        .alert("Delete", isPresented: $profileViewModel.isDeleteSuccess) {
            Button("Yes", role: .destructive) {
                profileViewModel.isConfirmationForPassword.toggle()
            }
            Button("No", role: .cancel) {
                print("User tapped No")
            }
        } message: {
            Text("Are you sure you want to delete?")
        }
        
        .alert("Comfirmation", isPresented: $profileViewModel.isConfirmationForPassword) {
            SecureField("Your Password", text: $profileViewModel.confirmationPassword)
                
            Button("Confirm", role: .destructive) {
                profileViewModel.checkPassword()
            }
            Button("Cancel", role: .cancel) {
                print("User tapped No")
                profileViewModel.confirmationPassword = ""
            }
        } message: {
            Text("Please confirm your password")
        }
        
        
        .alert("Logout", isPresented: $profileViewModel.isLogoutSuccess) {
            Button("Logout", role: .destructive) {
                profileViewModel.removeUserToken()
            }
            Button("No", role: .cancel) {
                print("User tapped No")
            }
        } message: {
            Text("Do you really want to logout?")
        }
        .onChange(of: profileViewModel.fcmTokenRemoved) {
            if profileViewModel.fcmTokenRemoved {
                Task {
                    // Clear messaging data before sign out
                    firebaseMessagesHelper.clearUserData()
                    
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
        .onChange(of: profileViewModel.accountDeleted) {
            if profileViewModel.accountDeleted {
                Task {
                    // Clear messaging data before account deletion
                    firebaseMessagesHelper.clearUserData()
                    
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
        .onAppear() {
            profileViewModel.userData = UserLoginCache.get()
            profileViewModel.getGamePlayedCount()
            profileViewModel.getAgeFromBirthdate()
        }
        .fullScreenCover(isPresented: $showPhotoPicker) {
            ImagePicker(selectedImage: $profileViewModel.image)
        }
        .onChange(of: profileViewModel.image) {
            if let image = profileViewModel.compressImage(profileViewModel.image) {
                ImageUploaderService.shared.upload(image) { result in
                    switch result {
                    case .success(let success):
                        print("success is \(success)")
                        profileViewModel.profilePic = success
                        profileViewModel.editProfileData()
                    case .failure(let failure):
                        print(failure)
                    }
                }
            }
            
        }
    }
    
    var headerView: some View {
        Text("Profile")
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundColor(.orange)
            .frame(maxWidth: .infinity)
    }
    
    var userProfileView: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .bottom) {
                // display uploaded profile image
                if let userData = UserLoginCache.get() {
//                    HStack {
//                        if let imgURL = URL(string: userData.profilePic ?? "") {
//                            JBAsyncImage(url: imgURL, placeholder: {
//                                ProgressView()
//                                    .tint(.orange)
//                            }, image: {
//                                Image(uiImage: $0).resizable()
//                            })
//                            .scaledToFill()
//                        } else {
//                            Image(systemName: "person.circle.fill")
//                                .resizable()
//                                .foregroundColor(.orange)
//                                .tint(.orange)
//                                .scaledToFill()
//                        }
//                    }.scaledToFill()
//                        .padding(.bottom, 80)
                    
                    if let imageURL = userData.profilePic, imageURL.count > 0 {
                        AsyncImage(url: URL(string: imageURL),
                                   scale: 1.0,
                                   transaction: .init(animation: .spring())) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .tint(.red)
                                    .scaleEffect(1)
                                    .transition(.opacity.combined(with: .scale))
                                    .frame(height: 300)
                                
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .transition(.opacity.combined(with: .scale))
                                    .id(imageURL)
                            case .failure(_):
                                Color.white.opacity(0.1)
                            @unknown default:
                                Color.white.opacity(0.2)
                            }
                        }
                                   .scaledToFill()
                                   .padding(.bottom, 80)
                    } else {
                        Image("profile-pic")
                            .resizable()
                            .scaledToFill()
                            .padding(.bottom, 80)
                    }
                } else {
                    Image("profile-pic")
                        .resizable()
                        .scaledToFill()
                        .padding(.bottom, 80)
                }
                
                VStack(alignment: .trailing) {
                    HStack {
                        Button{
                            showPhotoPicker.toggle()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 20)
                                .tint(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 8)
                                .background(.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 30))
                        }
                        Spacer()
                        Text("\(profileViewModel.age ?? 0) years")
                            .font(.system(size: 16, weight: .regular))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    .padding()
                    
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    if profileViewModel.userData?.basketballPosition != nil {
                        Text(profileViewModel.userData?.basketballPosition ?? "-")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.orange)
                            .padding()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            
                    }
                    VStack(alignment: .leading) {
                        Text("\(profileViewModel.userData?.username ?? "")")
                            .font(.system(size: 22, weight: .bold))
                        Text("\(profileViewModel.userData?.firstName ?? "") \(profileViewModel.userData?.lastName ?? "")")
                            .font(.system(size: 20, weight: .thin))
                    }
                    
                    Spacer()
                    
                    Button {
                        nav.path.append(Route.editProfileView)
                    } label: {
                        Image(systemName: "square.and.pencil.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                            .tint(.white)
                    }
                }
                .padding()
                .background(.orange)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(.bottom)
        .padding(.horizontal, 30)
    }
    
    var userRankAndPointView: some View {
        HStack {
            VStack {
                Text("# \(profileViewModel.userData?.ranking ?? 0)")
                    .font(.system(size: 30, weight: .bold))
                
                Text("Your Rank")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            VStack {
                Text("\(profileViewModel.userData?.gamePoints ?? 0)")
                    .font(.system(size: 30, weight: .bold))
                    .minimumScaleFactor(0.5)
                
                Text("Hoop Points")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            VStack {
                Text("\(profileViewModel.gamePlayed)")
                    .font(.system(size: 30, weight: .bold))
                
                Text("Games Played")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
        .frame(height: 80)
    }
    
    var extraOptionsView: some View {
        VStack {
            Button {
                nav.path.append(Route.gameHistoryView)
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "clock")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.orange)
                        .frame(width: 22, height: 20)
                    
                    Text("Game History")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 30)
            
            Button {
                
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "link")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.orange)
                        .frame(width: 22)
                    
                    Text("About Us")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 30)
            
            Button {
                
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "lock.shield")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.orange)
                        .frame(width: 22, height: 24)
                    
                    Text("Privacy & Terms")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 30)
            
            Button {
                
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "message")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.orange)
                        .frame(width: 22, height: 22)
                    
                    Text("Feedback")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 30)
            
            Button {
                
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.orange)
                        .frame(width: 22, height: 22)
                    
                    Text("Share App")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 30)
        }
    }
    
    var logoutAndDeleteAccountButtonView: some View {
        VStack(spacing: 16) {
            Text("App Version 1.0")
                .font(.system(size: 10, weight: .light))
            
            Button {
                profileViewModel.isLogoutSuccess.toggle()
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "iphone.and.arrow.forward.outward")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 22)
                        .foregroundStyle(.orange)
                    
                    Text("Logout")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.orange)
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 1)
                    .fill(.orange)
            }
            
            Button {
                profileViewModel.isDeleteSuccess.toggle()
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "xmark.bin")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 22)
                        .foregroundStyle(.red)
                    
                    Text("Delete Account")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                }
                .frame(height: 60)
                .frame(maxWidth: .infinity)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 30)
                    .stroke(lineWidth: 1)
                    .fill(.red)
            }
        }
        .padding(.vertical)
        .padding(.horizontal, 30)
    }
}

#Preview {
    ProfileView()
}
