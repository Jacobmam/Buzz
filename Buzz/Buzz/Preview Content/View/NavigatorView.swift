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
            Tab {
                HomeView()
                    .environmentObject(viewModel)
            }label: {
                Label("Home", systemImage: "house")
            }
        
        }
    }
}

#Preview {
    NavigatorView()
        .environmentObject(LoginViewModel())
}
