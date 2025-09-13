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
                    Label("Home", systemImage: "house")
                }
            
            FavoritesView()
                .tabItem {
                    Label("Fav", systemImage: "heart.fill")

                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
        }
        .tint(.orange)
        .background(.black)
    }
}

#Preview {
    NavigatorView()
       
}
