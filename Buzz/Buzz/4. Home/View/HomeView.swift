//
//  StartPageView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 16.02.25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var nav: NavigationManager
    @StateObject private var homeViewModel = HomeViewModel()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some View {
        ScrollView {
            VStack {
                ZStack {
                    Text("Buzz")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    HStack {
                        Spacer()
                        Button {
                            nav.path.append(Route.notificationsView)
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: "bell.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 26)
                                    .foregroundColor(.orange)
                            }
                            .frame(width: 80)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.orange)
                        .padding(.leading)
                    
                    Text(UserLoginCache.get()?.username ?? "" )
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                    
                    if let userProfile = homeViewModel.userProfile {
                        HStack {
                            Text("Ranking #\(userProfile.ranking)")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(userProfile.gamePoints) Game Points")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                    } else {
                        HStack {
                            ProgressView()
                            Text("Loading...")
                                .fontWeight(.thin)
                        }
                    }
                    
                    Divider()
                        .background(Color.white)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.3)))
                .padding()
                
                NavigationLink(destination: DeutschlandCourtView()) {
                    HomeFeatureCard(title: "Court Finder", description: "Entdecke die besten Basketball Courts in Deutschland! 🏀", image: "basketball.court")
                }
                
                Button {
                    nav.path.append(Route.userSelectionView)
                } label: {
                    HomeFeatureCard(title: "Matches", description: "Ob 1v1, 3v3 oder 5v5, fordere andere heraus und dominiere den Court!", image: "figure.basketball")
                }
                
                Button {
                    nav.path.append(Route.rankingBoardView)
                } label: {
                    HomeFeatureCard(title: "Ranking", description: "Perfektioniere deine Skills und werde jeden Tag besser.", image: "basketball")
                }
            }
            .padding()
        }
        .onAppear {
            appDelegate.registerForPushNotifications()
            
            Task {
                if let userData = UserLoginCache.get() {
                    let loginViewModel = LoginViewModel()
                    homeViewModel.userProfile = try await loginViewModel.find(by: userData.id)
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onReceive(NotificationCenter.default.publisher(for: .navigateToNotificationsView)) { _ in
            nav.path.append(Route.notificationsView)
        }
//        .navigate(to: RequestView(),
//                  when: $homeViewModel.navigateToRequestView)
//        .navigate(to: UserView(),
//                  when: $homeViewModel.navigateToUserSelectionView)
    }
}


struct HomeFeatureCard: View {
    var title: String
    var description: String
    var image: String
    
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Text(title)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text(description)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 2)
                    .multilineTextAlignment(.center)
            }
            
            Image(systemName: image)
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.5)))
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
    
}
