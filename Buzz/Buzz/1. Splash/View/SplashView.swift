import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var nav: NavigationManager
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    @EnvironmentObject private var firebaseMessagesHelper: FirebaseMessagesHelper
    @EnvironmentObject private var firebaseCommonClass: FirebaseCommonClass

    @State private var isAnimating = false
    @State private var isAnimationCompleted = false
    @State private var hideLogo = false
    
    var body: some View {
        if !isAnimationCompleted {
            ZStack {
                Image("applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: isAnimating ? 350 : 600, height: isAnimating ? 350 : 600)
                    .opacity(hideLogo ? 0 : 1)
                    .onAppear {
                        withAnimation(.easeOut(duration: 1)) {
                            isAnimating = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeOut(duration: 2)) {
                                hideLogo = true
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { // Verzögerung für reibungslosen Übergang
                            isAnimationCompleted = true
                        }
                    }
            }
            .animation(.easeInOut(duration: 2), value: isAnimationCompleted)
        } else {
            NavigationStack(path: $nav.path) {
                Group {
                    if userStateViewModel.isFirstTimeAppOpen == true {
                        SelectLanguageView()
                        
                    } else if userStateViewModel.isLoggedIn == true {
                        NavigatorView()
//                        SelectLanguageView()
                    } else {
                        LoginView()
                    }
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .navigatorView:
                        NavigatorView()
                            .navigationBarBackButtonHidden(true)
                    case .loginView:
                        LoginView()
                            .navigationBarBackButtonHidden(true)
                    case .registerView:
                        RegisterView()
                            .navigationBarBackButtonHidden(true)
                    case .notificationsView:
                        RequestView()
                            .navigationBarBackButtonHidden(true)
                    case .userSelectionView:
                        UserView()
                            .navigationBarBackButtonHidden(true)
                    case .gameModeView(let opponentUser):
                        GameModeView(opponentUser: opponentUser)
                            .navigationBarBackButtonHidden(true)
                    case .gameScoreboardView(let requestId):
                        GameScoreboardView(requestId: requestId)
                            .navigationBarBackButtonHidden(true)
                    case .rankingBoardView:
                        RankingBoardView()
                            .navigationBarBackButtonHidden(true)
                    case .forgotPasswordView:
                        ForgotPasswordView()
                            .navigationBarBackButtonHidden(true)
                    case .editProfileView:
                        EditProfileView()
                            .navigationBarBackButtonHidden(true)
                    case .searchUsersView:
                        SearchUsersView()
                            .navigationBarBackButtonHidden(true)
                    case .searchUserProfileView(let searchedUser):
                        SearchUserProfileView(searchedUser: searchedUser)
                            .navigationBarBackButtonHidden(true)
                    case .messageChatRoomView:
                        MessageChatRoomsView()
                            .navigationBarBackButtonHidden(true)
                    case .messageConversationView(let chatRoom):
                        MessageConversationView(chatRoom: chatRoom)
                            .navigationBarBackButtonHidden(true)
                    case .gameHistoryView:
                        GameHistoryView()
                            .navigationBarBackButtonHidden(true)
                    case .courtFinderView:
                        CourtFinderView()
                            .navigationBarBackButtonHidden(true)
                    case .webView(let WebviewName):
                        WebPageView(webviewName: WebviewName)
                            .navigationBarBackButtonHidden(true)
                    case .selectLanguageView:
                        SelectLanguageView()
                            .navigationBarBackButtonHidden(true)
                    default: EmptyView()
                    }
                }
            }
            .onChange(of: userStateViewModel.isLoggedIn) {
                nav.reset()
                
                // Handle messaging when login state changes
                if userStateViewModel.isLoggedIn == true {
                    // User logged in - start observing chat rooms
                    if let userId = UserLoginCache.get()?.id {
                        firebaseMessagesHelper.observeChatRooms(for: userId)
                    }
                } else {
                    // User logged out - clear messaging data
                    firebaseMessagesHelper.clearUserData()
                }
            }
            .onAppear {
                firebaseCommonClass.fetchSettings()
                // Initial setup when app launches
                if let userId = UserLoginCache.get()?.id {
                    firebaseMessagesHelper.observeChatRooms(for: userId)
                }
            }
        }
    }
}

#Preview {
    SplashView()
    
}
