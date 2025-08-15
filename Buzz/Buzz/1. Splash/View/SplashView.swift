import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var nav: NavigationManager
    @EnvironmentObject var userStateViewModel: UserStateViewModel
    
    @State private var isAnimating = false
    @State private var isAnimationCompleted = false
    @State private var hideLogo = false
    
    var body: some View {
        if !isAnimationCompleted {
            ZStack {
                Image("3")
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
                    if userStateViewModel.isLoggedIn == true {
                        NavigatorView()
                    } else {
                        LoginView()
                    }
                }
                .navigationDestination(for: Route.self) { route in
                    switch route {
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
                    default: EmptyView()
                    }
                }
            }
            .onChange(of: userStateViewModel.isLoggedIn) {
                nav.reset()
            }
        }
    }
}

#Preview {
    SplashView()
    
}
