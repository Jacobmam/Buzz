//
//  NavigatorView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 26.02.25.
//

import SwiftUI

struct NavigatorView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(viewModel) 
                .tabItem {
                    Label("Home", systemImage: "house")
                }
           
        }
        .tint(.orange)
    }
}

#Preview {
    NavigatorView()
        .environmentObject(LoginViewModel())
}
