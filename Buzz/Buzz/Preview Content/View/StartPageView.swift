//
//  StartPageView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 16.02.25.
//

import SwiftUI

struct StartPageView: View {
    @State private var userProfile = UserProfile(username: "BlvckVenom")
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("Buzz")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                        .padding(.leading, 20)
                        .padding(.top, 10)
                    Spacer()
                }
                
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.orange)
                    
                    Text(userProfile.username)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Ranking: \(userProfile.ranking) | Play Points: \(userProfile.gamePoints)")
                        .font(.headline)
                        .foregroundColor(.gray)
                
                }
                
                Button(action: {
                    print("Find Court pressed")
                }) {
                    Text("Find Court")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    StartPageView()
}
