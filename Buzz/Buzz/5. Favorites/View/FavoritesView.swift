//
//  FavoritesView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 16.03.25.
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var favoriteViewModel = FavoriteViewModel()
    
    var body: some View {
        ZStack {
            
            VStack {
                Text("Favoriten")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                    .padding(.top, 20)
                
                List {
                    ForEach(favoriteViewModel.favoriteCourts) { court in
                        HStack {
                            Text(court.name)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(Color.orange.opacity(0.2)))
                        .listRowBackground(Color.clear)
                        .swipeActions {
                            Button(role: .destructive) {
                                Task {
                                    await favoriteViewModel.delete(courtID: court.id)
                                }
                            } label: {
                                Label("Löschen", systemImage: "trash")
                            }
                            .tint(.orange)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    FavoritesView()
}
