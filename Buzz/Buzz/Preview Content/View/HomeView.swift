//
//  StartPageView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 16.02.25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    @Environment(FavoriteViewModel.self) var favoriteViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Buzz")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.top)

                    VStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.orange)
                        
                        Text(viewModel.userProfile?.username ?? "")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Rankings: #\(viewModel.userProfile?.ranking ?? 0)")
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(viewModel.userProfile?.gamePoints ?? 0) Game Points")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .background(Color.white)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.3)))
                    .padding()

                    NavigationLink(destination: DeutschlandCourtView().environment(favoriteViewModel)) {
                        HomeFeatureCard(title: "Court Finder", description: "Entdecke die besten Basketball Courts in Deutschland! 🏀", image: "basketball.court")
                    }
                    HomeFeatureCard(title: "Matches", description: "Ob 1v1, 3v3 oder 5v5, fordere andere heraus und dominiere den Court!", image: "figure.basketball")
                    HomeFeatureCard(title: "Practice", description: "Perfektioniere deine Skills und werde jeden Tag besser.", image: "basketball")
                }
                .padding()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
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
        .environmentObject(LoginViewModel())
}
