//
//  SelectLanguageView.swift
//  Buzz
//
//  Created by Jay Borania on 01/12/25.
//

import SwiftUI

struct SelectLanguageView: View {
    @EnvironmentObject private var nav: NavigationManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedLanguage: String = ""
    let supportedLanguages = [("English", "English", "en"), ("Deutsch", "German","de")]
    var body: some View {
        VStack {
            headerView
            languageInfoView
            languageSelectionView
            Spacer()
            cuntinueButtonView
        }
        .padding(.horizontal,24)
        .onAppear {
            selectedLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        }
    }
    var headerView: some View {
        HStack {
            ZStack(alignment: .leading) {
                if userStateViewModel.isFirstTimeAppOpen == false {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .tint(.white)
                            .frame(height: 17)
                        //                        .bold()
                    }
                    .frame(width: 24, height: 24)
                    //                Spacer()
                }
                HStack {
                    Spacer()
                    CustomTextView(text: "Language".localized, textSize: 14, fontType: .POPPINS_SEMIBOLD, textColor: .white)
                    Spacer()

                }
            }
           
        }
    }
    var languageInfoView: some View {
        VStack (spacing: 0){
            Image("language_translate")
                .resizable()
                .scaledToFit()
                .frame(width: 212, height: 212)
            CustomTextView(text: "Choose Language", textSize: 30, fontType: .POPPINS_BOLD, textColor: .white)
                .padding(10)
            CustomTextView(text: "Choose your preferred language for the app, you can adjust it later in the More Menu.", textSize: 14, fontType: .POPPINS_REGULAR, textColor: .white,textAlignment: .center)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    var languageSelectionView: some View {
        VStack(alignment: .leading) {
            ForEach(supportedLanguages, id: \.0) { languageName, languageSubName, languageCode in
                Button {
                    selectedLanguage = languageCode
                    languageManager.setLanguage(selectedLanguage)
                } label: {
                    HStack {
                        Image(languageName)
                            .resizable()
                            .frame(width: 60, height: 60)
                            .clipShape(.circle)
                            .overlay(
                                Circle().stroke(.white, lineWidth: 1)
                                  
                            )
                        VStack (alignment: .leading){
                            CustomTextView(text: languageName, textSize: 18, fontType: .POPPINS_BOLD, textColor: .white)
                            CustomTextView(text: languageSubName, textSize: 12, fontType: .POPPINS_BOLD, textColor: .white)
                        }
                        Spacer()
                        Image(systemName: languageCode == selectedLanguage ? "checkmark.circle.fill" : "circle")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .tint(languageCode == selectedLanguage ? .orange : AppColors.greyText)
                    }
                    .padding(15)
                    .background( LinearGradient(
                        gradient: Gradient(colors: [
                            Color(AppColors.lightGrey),
                            Color(AppColors.black)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                }
                
            }
        }
    }
    var cuntinueButtonView: some View {
        Button {
            if userStateViewModel.isFirstTimeAppOpen == true {
                userStateViewModel.isFirstTimeAppOpen = false
                if userStateViewModel.isLoggedIn == true {
                    nav.path.append(Route.navigatorView)
//                        SelectLanguageView()
                } else {
                    nav.path.append(Route.loginView)
                }
            } else {
                nav.reset()
            }
           
        } label: {
            CustomTextView(text: userStateViewModel.isFirstTimeAppOpen == true ? "CONTINUE" : "DONE", textSize: 14, fontType: .POPPINS_SEMIBOLD, textColor: .white)
                .padding()
                .frame(maxWidth: .infinity)
        }
        .background(AppColors.primaryColor)
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .padding()
        
    }
}

#Preview {
    SelectLanguageView()
}
//firebase deploy --only firestore:sendMessageNotification
