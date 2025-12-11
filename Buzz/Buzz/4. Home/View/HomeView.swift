//
//  StartPageView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 16.02.25.
//

import SwiftUI
import MapKit

struct HomeView: View {
    @EnvironmentObject private var nav: NavigationManager
    @EnvironmentObject private var appDelegate: AppDelegate
    @EnvironmentObject private var firebaseMessagesHelper: FirebaseMessagesHelper
    @StateObject private var homeViewModel = HomeViewModel()
    let columns = [
         GridItem(.fixed(20), alignment: .leading),
         GridItem(.flexible(), alignment: .leading),
         GridItem(.fixed(30), alignment: .leading),
         GridItem(.fixed(30), alignment: .leading),
         GridItem(.fixed(30), alignment: .leading),
         GridItem(.fixed(30), alignment: .leading),
         GridItem(.fixed(40), alignment: .leading)
     ]
    @State private var snapshots: [UUID: UIImage] = [:]

    var body: some View {
        ZStack {
            VStack (spacing: 39){
                headerView
                
                ScrollView {
                    VStack (spacing: 40) {
                        greetingsView
                        AdsView
                        RankingView
                        matchesButtonView
                        nearbyCourtFinderView
//                        top10RankingView
                    }
                    
                    //                    VStack(spacing: 0) {
                    //                        VStack {
                    //                            HStack(spacing: 0) {
                    //                                HStack {
                    //                                    if let imgURL = URL(string: homeViewModel.userProfile?.profilePic ?? "") {
                    //                                        JBAsyncImage(url: imgURL, placeholder: {
                    //                                            ProgressView()
                    //                                                .tint(.orange)
                    //                                        }, image: {
                    //                                            Image(uiImage: $0).resizable()
                    //                                        })
                    //                                        .id(imgURL)
                    //                                        .scaledToFill()
                    //                                    } else {
                    //                                        Image(systemName: "person.circle.fill")
                    //                                            .resizable()
                    //                                            .foregroundColor(.orange)
                    //                                            .tint(.orange)
                    //                                            .scaledToFill()
                    //                                    }
                    //                                }.frame(width: 60, height: 60)
                    //                                    .clipShape(Circle())
                    //                                    .padding(.trailing)
                    //
                    //
                    //
                    //                                VStack(alignment: .leading, spacing: 4) {
                    //                                    Text("\(homeViewModel.userProfile?.username ?? "")")
                    //                                        .font(.system(size: 20, weight: .bold))
                    //                                    Text("\(homeViewModel.userProfile?.firstName ?? "") \(homeViewModel.userProfile?.lastName ?? "")")
                    //                                        .font(.system(size: 16, weight: .thin))
                    //                                }
                    //                                Spacer()
                    //
                    //                            }
                    ////                            .padding()
                    //                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.5)))
                    //
                    //
                    //                            Divider()
                    //                                .background(Color.white)
                    //                                .padding(.vertical,5)
                    //
                    //                            HStack {
                    //                                Text("Ranking #\(homeViewModel.userProfile?.ranking ?? 0)")
                    //                                    .foregroundColor(.white)
                    //                                    .padding(.vertical,4)
                    //                                    .padding(.horizontal)
                    //                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.5)))
                    //
                    //                                Spacer()
                    //
                    //                                Text("\(homeViewModel.userProfile?.gamePoints ?? 0) Hoop Points")
                    //                                    .foregroundColor(.white)
                    //                                    .padding(.vertical,4)
                    //                                    .padding(.horizontal)
                    //                                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.5)))
                    //                            }
                    //                        }
                    ////                        .padding()
                    //
                    //                        VStack {
                    //                            Button {
                    //                                nav.path.append(Route.courtFinderView)
                    //                            } label: {
                    //                                HomeFeatureCard(title: LocalizedStringKey("Court Finder"), description: "Entdecke die besten Basketball Courts in Deutschland! 🏀", image: "sportscourt")
                    //                            }
                    //                            Button {
                    //                                nav.path.append(Route.userSelectionView)
                    //                            } label: {
                    //                                HomeFeatureCard(title: "Matches", description: "Ob 1v1, 3v3 oder 5v5, fordere andere heraus und dominiere den Court!", image: "figure.basketball")
                    //                            }
                    //                            Button {
                    //                                nav.path.append(Route.rankingBoardView)
                    //                            } label: {
                    //                                HomeFeatureCard(title: "Ranking", description: "Perfektioniere deine Skills und werde jeden Tag besser.", image: "basketball")
                    //                            }
                    //                        }
                    //                    }
                    //                    .padding(.vertical)
                    //                    .padding(.horizontal,24)
                }
                .scrollIndicators(.hidden)
            }
            if homeViewModel.isLoading {
                JBLoadingView()
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical)
        
        .onAppear {
            appDelegate.registerForPushNotifications()
            //            homeViewModel.getUserData()
            homeViewModel.fetchUsers()
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
        HStack(spacing: 15) {
            HStack(alignment: .center) {
                Image("SplashBasketball")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32)
                CustomTextView(text: "BUZZ", textSize: 27, fontType: .ANTICDIDONE, textColor: AppColors.primaryColor)
                    .fontWeight(.medium)
            }
            Spacer()
            Button {
                nav.path.append(Route.searchUsersView)
            } label: {
                VStack(spacing: 4) {
                    Image("search")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 22)
                        .foregroundColor(.orange)
                }
            }
            
            Button {
                nav.path.append(Route.messageChatRoomView)
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image("messages")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 24)
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
            
            Button {
                nav.path.append(Route.notificationsView)
            } label: {
                VStack(spacing: 4) {
                    Image("notification")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 23)
                        .foregroundColor(.orange)
                }
            }
            
            
        }
        //        .padding(.vertical)
    }
    var greetingsView: some View {
        HStack(spacing: 0) {
            //            Text("\(HelperClass.shared.greetingMessage()) \(homeViewModel.userProfile?.firstName ?? "") \(homeViewModel.userProfile?.lastName ?? "")")
            CustomTextView(text: HelperClass.shared.greetingMessage(), textSize: 16, fontType: .POPPINS_SEMIBOLD, textColor: .white)
            CustomTextView(text: ", \(homeViewModel.userProfile?.firstName ?? "") \(homeViewModel.userProfile?.lastName ?? "")", textSize: 16, fontType: .POPPINS_LIGHT, textColor: .white)
            //            CustomTextView(text: " Mansi Borania", textSize: 16, fontType: .POPPINS_LIGHT, textColor: .white)
            Spacer()
            HStack {
                if let imgURL = URL(string: homeViewModel.userProfile?.profilePic ?? "") {
                    JBAsyncImage(url: imgURL, placeholder: {
                        ProgressView()
                            .tint(.orange)
                    }, image: {
                        Image(uiImage: $0).resizable()
                    })
                    .id(imgURL)
                    .scaledToFill()
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .foregroundColor(AppColors.primaryColor)
                        .tint(.orange)
                        .scaledToFill()
                }
            }.frame(width: 50, height: 50)
                .clipShape(Circle())
        }
    }
    var AdsView: some View {
//        ZStack(alignment: .bottomTrailing) {
//            HStack {
//                VStack(alignment: .leading) {
//                    HStack(spacing: 4) {
//                        Image("basketball")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 12)
//                        CustomTextView(text: "basketball", textSize: 11, fontType: .POPPINS_MEDIUM, textColor: .black)
//                    }
//                    .padding(.vertical,4)
//                    .padding(.horizontal,6)
//                    .background(.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//                    CustomTextView(text: "We will".localized, textSize: 18, fontType: .POPPINS_SEMIBOLD, textColor: .white, textAlignment: .leading)
//                    CustomTextView(text: "Show here some", textSize: 18, fontType: .POPPINS_SEMIBOLD, textColor: .white, textAlignment: .leading)
//                    CustomTextView(text: "News or Ads ", textSize: 18, fontType: .POPPINS_SEMIBOLD, textColor: .white, textAlignment: .leading)
//                    CustomTextView(text: "We can show ads here", textSize: 12, fontType: .POPPINS_REGULAR, textColor: .white, textAlignment: .leading)
//                }
//                .padding(.horizontal, 21)
//                .padding(.vertical,25)
//                Spacer()
//            }
//            .background( LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(AppColors.primaryColor),
//                    Color(AppColors.darkPrimaryColor)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            ))
//            .clipShape(RoundedRectangle(cornerRadius: 25))
//            Image("Player")
//                .resizable()
//                .scaledToFill()
//                .frame(width: 160, height: 220)
//                .clipShape(RoundedRectangle(cornerRadius: 25))
//            
//        }
//        .padding(.top, -40)
        VStack {
            Image("add")
                .resizable()
                .frame(height: 211)

        }
        
    }
    
    var RankingView: some View {
        HStack {
            VStack {
                CustomTextView(text: "\(homeViewModel.userProfile?.ranking ?? 0)", textSize: 30, fontType: .POPPINS_SEMIBOLD, textColor: .white)
                CustomTextView(text: "Ranking", textSize: 12, fontType: .POPPINS_REGULAR, textColor: .white)
            }
            .padding()
            .frame(width: 114, height: 116)
            .background( LinearGradient(
                gradient: Gradient(colors: [
                    Color(AppColors.primaryColor),
                    Color(AppColors.darkPrimaryColor)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .clipShape(RoundedRectangle(cornerRadius: 25))
            Spacer()
            VStack {
                CustomTextView(text: "\(homeViewModel.userProfile?.gamePoints ?? 0)"
                               , textSize: 30, fontType: .POPPINS_SEMIBOLD, textColor: .white)
                CustomTextView(text: "Hoop Points", textSize: 12, fontType: .POPPINS_REGULAR, textColor: .white)
            }
            .padding()
            .frame(width: 114, height: 116)
            .background( LinearGradient(
                gradient: Gradient(colors: [
                    Color(AppColors.primaryColor),
                    Color(AppColors.darkPrimaryColor)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .clipShape(RoundedRectangle(cornerRadius: 25))
            Spacer()
            VStack {
                CustomTextView(text: "29", textSize: 30, fontType: .POPPINS_SEMIBOLD, textColor: .white)
                CustomTextView(text: "Total Match", textSize: 12, fontType: .POPPINS_REGULAR, textColor: .white)
            }
            .padding()
            .frame(width: 114, height: 116)
            .background( LinearGradient(
                gradient: Gradient(colors: [
                    Color(AppColors.primaryColor),
                    Color(AppColors.darkPrimaryColor)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }
    var matchesButtonView: some View {
        VStack (spacing: 0) {
            HStack {
                VStack (alignment: .leading, spacing: 10) {
                    CustomTextView(text: "Matches",
                                   textSize: 20,
                                   fontType: .POPPINS_BOLD,
                                   textColor: .white)
                    //                .padding(.vertical)
                    CustomTextView(text: "Whether 1v1, 3v3 or 5v5, challenge others and dominate the court!",
                                   textSize: 14,
                                   fontType: .POPPINS_REGULAR,
                                   textColor: .white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    Button {
                        nav.path.append(Route.userSelectionView)
                    } label: {
                        CustomTextView(text: "SEND INVITE", textSize: 12, fontType: .POPPINS_SEMIBOLD, textColor: .white)
                    }
                    .padding(.vertical, 7)
                    .padding(.horizontal, 15)
                    .background(AppColors.primaryColor)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                Spacer()
                Image("Frame")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 151)
                
            }
            .padding(.horizontal, 21)
            .padding(.vertical, 20)
            .background(LinearGradient(
                gradient: Gradient(colors: [
                    Color(AppColors.lightGrey),
                    Color(AppColors.black)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            Rectangle()
                .foregroundColor(.orange)
                .background(AppColors.primaryColor)
                .frame(height: 6)
        }
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
    var nearbyCourtFinderView: some View {
        VStack {
            HStack {
                CustomTextView(text: "Near by Court Finder", textSize: 18, fontType: .POPPINS_BOLD, textColor: .white)
                    .padding(.vertical)
                    .multilineTextAlignment(.leading)
                Spacer()
                Button {
                    nav.path.append(Route.courtFinderView(homeViewModel: homeViewModel))
                } label: {
                    CustomTextView(text: "View All", textSize: 10, fontType: .POPPINS_REGULAR, textColor: .white)
                        .padding(.vertical)
                        .multilineTextAlignment(.leading)
                }
            }
            ForEach(homeViewModel.courts.prefix(3)) { court in
                Button {
                    openInAppleMaps(court.mapItem)
                } label: {
                    VStack (spacing: 0) {
                        HStack (spacing: 10 ) {
                            if let img = snapshots[court.id] {
                                            Image(uiImage: img)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 102, height: 102)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                                .clipped()
                                        } else {
                                            // placeholder
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.gray.opacity(0.2))
                                                .frame(width: 102, height: 102)
                                                .overlay(ProgressView())
                                        }
        //                    Image("map")
        //                        .resizable()
        //                        .scaledToFit()
        //                        .frame(height: 102)
        //                        .clipShape(RoundedRectangle(cornerRadius: 12))
                            VStack (alignment: .leading) {
                                CustomTextView(text: court.mapItem.name ?? "",
                                               textSize: 20,
                                               fontType: .POPPINS_BOLD,
                                               textColor: .white)
                                //                .padding(.vertical)
                                CustomTextView(text: court.mapItem.placemark.title ?? "",
                                               textSize: 10,
                                               fontType: .POPPINS_REGULAR,
                                               textColor: .white)
                                .multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                Spacer()
                                //                        Button {
                                //                            nav.path.append(Route.userSelectionView)
                                //                        } label: {
                                //                            CustomTextView(text: "SEND INVITE", textSize: 12, fontType: .POPPINS_SEMIBOLD, textColor: .white)
                                //                        }
                                //                        .padding(.vertical, 7)
                                //                        .padding(.horizontal, 15)
                                //                        .background(AppColors.primaryColor)
                                //                        .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 21)
                        .padding(.vertical, 20)
                        .background(LinearGradient(
                            gradient: Gradient(colors: [
                                Color(AppColors.lightGrey),
                                Color(AppColors.black)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        Rectangle()
                            .foregroundColor(.orange)
                            .background(AppColors.primaryColor)
                            .frame(height: 6)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                }
           
            .task {
                    if snapshots[court.id] == nil,
                       let coord = court.mapItem.placemark.location?.coordinate {

                        snapshots[court.id] = await MapSnapshotManager.shared.snapshot(for: coord)
                    }
                }
        }
            
        }
    }
    
    var top10RankingView: some View {
        VStack (alignment: .leading) {
            CustomTextView(text: "Top 10 Ranking", textSize: 18, fontType: .POPPINS_BOLD, textColor: .white)
                .padding(.vertical)
                .multilineTextAlignment(.leading)
            VStack {
                LazyVGrid(columns: columns, spacing: 10) {

                               // Header
                    CustomTextView(text: "#", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
                    CustomTextView(text: "Team", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
                    CustomTextView(text: "P", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
                    CustomTextView(text: "W", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
                    CustomTextView(text: "T", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
                    CustomTextView(text: "L", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
                    CustomTextView(text: "Pts", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
                               // Dynamic rows
//                    ForEach(homeViewModel.arrUsers, id: \.self) { user in
//                        CustomTextView(text: "1", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
//                        CustomTextView(text: user.firstName, textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
//                        CustomTextView(text: "P", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
//                        CustomTextView(text: "W", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
//                        CustomTextView(text: "T", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
//                        CustomTextView(text: "L", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
//                        CustomTextView(text: "\(user.gamePoints)", textSize: 14, fontType: .POPPINS_MEDIUM, textColor: AppColors.primaryColor)
//                    }
//                        HStack {
//                            Text("\(user.ranking)")
//                                .foregroundColor(.white)
//                            
//                            Text(user.username)
//                                .bold()
//                                .foregroundColor(.white)
//                            
//                            Spacer()
//                            
//                            Text("\(user.gamePoints)")
//                                .foregroundColor(.white)
//                        }
//                        .padding()
//                        .background((UserLoginCache.get()?.id == user.id) ? .orange : .clear)
//                        .cornerRadius(10)
//                        .overlay {
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(lineWidth: 0.5)
//                                .fill(.white)
//                        }
//                        .padding(.horizontal, 30)
//                        .onAppear {
//                            if let lastUser = homeViewModel.arrUsers.last,
//                               user == lastUser {
//                                homeViewModel.loadMoreUsers()
//                            }
//                        }
//                    }
                           }
//                Spacer()
//                    .frame(width:.infinity, height: 3)
//                    .background(AppColors.lightGrey)
//                ScrollView {
//                        LazyVStack(spacing: 20) {
//                  
//                            
//                            if homeViewModel.isLoading {
//                                ProgressView("Loading more...")
//                                    .padding()
//                            }
//                        }
//                        .padding(.top)
//                    }
                
            }
        }
    }
    private func openInAppleMaps(_ mapItem: MKMapItem) {
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}



#Preview {
    HomeView()
    
}
