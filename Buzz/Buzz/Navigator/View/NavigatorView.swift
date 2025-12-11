//
//  NavigatorView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 26.02.25.
//

import SwiftUI

struct NavigatorView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", image: "house")
                        .tint(.white)
                }
            
//            FavoritesView()
//                .tabItem {
//                    Label("Fav", systemImage: "heart.fill")
//
//                }
            ProfileView()
                .tabItem {
                    Label("Profile", image: "user")
                }
        }
        .tint(.orange)
        .background(.black)
    }
}

#Preview {
    NavigatorView()
       
}
