//
//  StartPageView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 16.02.25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var nav: NavigationManager
    @EnvironmentObject private var appDelegate: AppDelegate
    @EnvironmentObject private var firebaseMessagesHelper: FirebaseMessagesHelper
    @StateObject private var homeViewModel = HomeViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                headerView
                
                ScrollView {
                    VStack(spacing: 0) {
                        VStack {
                            HStack(spacing: 0) {
                                // display profile image
                                if let imageURL = homeViewModel.userProfile?.profilePic, imageURL.count > 0 {
                                    AsyncImage(url: URL(string: imageURL),
                                               scale: 1.0,
                                               transaction: .init(animation: .spring())) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .tint(.orange)
                                                .scaleEffect(1)
                                                .transition(.opacity.combined(with: .scale))
                                                .frame(width: 60, height: 60)
                                                .padding(.trailing)
                                            
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .transition(.opacity.combined(with: .scale))
                                                .frame(width: 60, height: 60)
                                                .clipShape(Circle())
                                                .padding(.trailing)
                                                .id(imageURL)
                                        case .failure(_):
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .foregroundColor(.orange)
                                                .tint(.orange)
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .padding(.trailing)
                                        @unknown default:
                                            Image(systemName: "person.circle.fill")
                                                .resizable()
                                                .foregroundColor(.orange)
                                                .tint(.orange)
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .padding(.trailing)
                                        }
                                    }
                                               .scaledToFill()
                                    
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.orange)
                                        .tint(.orange)
                                        .scaledToFill()
                                        .frame(width: 50, height: 50)
                                        .padding(.trailing)
                                    
                                }
                                
                                //                            Spacer()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(homeViewModel.userProfile?.username ?? "")")
                                        .font(.system(size: 20, weight: .bold))
                                    Text("\(homeViewModel.userProfile?.firstName ?? "") \(homeViewModel.userProfile?.lastName ?? "")")
                                        .font(.system(size: 16, weight: .thin))
                                }
                                Spacer()
                                
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.5)))
                            
                            
                            Divider()
                                .background(Color.white)
                                .padding(.vertical,5)
                            
                            HStack {
                                Text("Ranking #\(homeViewModel.userProfile?.ranking ?? 0)")
                                    .foregroundColor(.white)
                                    .padding(.vertical,4)
                                    .padding(.horizontal)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.5)))
                                
                                Spacer()
                                
                                Text("\(homeViewModel.userProfile?.gamePoints ?? 0) Hoop Points")
                                    .foregroundColor(.white)
                                    .padding(.vertical,4)
                                    .padding(.horizontal)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.5)))
                            }
                        }
                        .padding()
                        
                        VStack {
                            Button {
                                //                            NavigationLink(destination: DeutschlandCourtView()) {
                                //                        nav.path.append(Route.userSelectionView)
                            } label: {
                                HomeFeatureCard(title: "Court Finder", description: "Entdecke die besten Basketball Courts in Deutschland! 🏀", image: "sportscourt")
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
                    }
                    .padding()
                }
            }
            if homeViewModel.isLoading {
                JBLoadingView()
            }
        }
        .onAppear {
            appDelegate.registerForPushNotifications()
            //            homeViewModel.getUserData()
            Task {
                if let userData = UserLoginCache.get() {
                    let loginViewModel = LoginViewModel()
                    guard let userDataId = userData.id else { return }
                    homeViewModel.userProfile = try await loginViewModel.find(by: userDataId)
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onReceive(NotificationCenter.default.publisher(for: .navigateToNotificationsView)) { _ in
            nav.path.append(Route.notificationsView)
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToMessageView)) { notification in
            if let chatId = notification.userInfo?["chatRoomId"] as? String {
                print("chatRoomId is \(chatId)")
                if let chatroom = firebaseMessagesHelper.chatRooms.first(where: { $0.id == chatId }) {
                    nav.path.append(Route.messageConversationView(chatRoom: chatroom))
                }
            }
//            nav.path.append(Route.messageChatRoomView)
        }
    }
    
    var headerView: some View {
        HStack(spacing: 20) {
            Text("Buzz")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.orange)
            Spacer()
            Button {
                nav.path.append(Route.searchUsersView)
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 26)
                        .foregroundColor(.orange)
                }
            }
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
            }
            
            Button {
                nav.path.append(Route.messageChatRoomView)
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "message.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 26)
                        .foregroundColor(.orange)
                    
                    let chatRooms = firebaseMessagesHelper.chatRooms.filter({ ($0.unreadCount ?? 0) > 0 })
                    if chatRooms.count > 0 {
                        Text("\(chatRooms.count)")
                            .font(.system(size: 14))
                            .foregroundStyle(.orange)
                            .padding(6)
                            .background(.white)
                            .clipShape(Circle())
                            .offset(y: -10)
                    }
                }
            }
        }
        .padding()
        .padding(.horizontal)
    }
}


struct HomeFeatureCard: View {
    var title: String
    var description: String
    var image: String
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 50)
                .foregroundColor(.white)
                .padding(.trailing)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(description)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 15, weight: .light))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Image(systemName: "hand.tap.fill")
                .resizable()
                .frame(width: 20, height: 23)
                .foregroundColor(.white)
                .padding(.leading)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.5)))
        .padding(.horizontal)
    }
}

#Preview {
    HomeView()
    
}
