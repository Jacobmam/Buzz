//
//  NavigatorView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 26.02.25.
//

import SwiftUI

struct NavigatorView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    @State var favoriteModel = FavoriteViewModel()

    var body: some View {
        TabView {
            HomeView()
                .environment(favoriteModel)
                .environmentObject(viewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            FavoritesView()
                .environment(favoriteModel)
                .environmentObject(viewModel)
                .tabItem {
                    Label("Fav", systemImage: "heart.fill")

                }
        }
        .tint(.orange) 
    }
}

#Preview {
    NavigatorView()
        .environmentObject(LoginViewModel())
}
