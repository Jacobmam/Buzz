//
//  DortmundCourtView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 07.03.25.
//

import SwiftUI

struct DortmundCourtView: View {
    var city: String
    @Environment(\.presentationMode) var presentationMode
    @Environment(FavoriteViewModel.self) var favoriteViewModel
    @State private var courts: [Court] = []
    @State private var isLoading = true
    
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.orange)
                            .imageScale(.large)
                    }
                    Spacer()
                }
                .padding(.leading)
                .padding(.top, 10)

                Text("\(city) Courts")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.orange)
                    .padding(.top, 5)

                Divider()
                    .background(Color.orange)

                if isLoading {
                    ProgressView("Lade Courts...")
                        .foregroundColor(.white)
                        .padding()
                } else {
                    ScrollView {
                        VStack {
                            ForEach(courts, id: \.name) { court in
                                CourtItemView4(court: court)
                                   .environment(favoriteViewModel)
                            }
                        }
                        .background(Color.black)
                    }
                }
            }
            .padding(.bottom, 5)
        }
        .onAppear(perform: fetchCourts)
    }
    
    func fetchCourts() {
        let repository = CourtRepository()
        repository.fetchCourts { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedCourts):
                    self.courts = fetchedCourts.filter { $0.city.lowercased() == city.lowercased() }
                    self.isLoading = false
                case .failure(let error):
                    print("Fehler beim Laden der Courts: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }
    }
}


struct CourtItemView4: View {
    @State private var isLiked = false
    @State private var likeCount = 0
    @Environment(FavoriteViewModel.self) var favoriteViewModel
    var court: Court
    @State private var showAlert = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(court.name)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.vertical, 5)

            AsyncImage(url: URL(string: court.imageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(10)

            HStack {
                Button(action: {
                    favoriteViewModel.addCourt(court: court)
                    showAlert = true
                }) {
                    Text("Hinzufügen")
                }
                .buttonStyle(.bordered)
                .alert("Erfolgreich Hinzugefügt", isPresented: $showAlert) {
                    Button("Ok", role: .cancel) {}
                }
            }
            .foregroundColor(.white.opacity(0.8))
            .padding(.vertical, 5)

            Text(court.address)
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 10)

            Divider()
                .background(Color.orange.opacity(0.5))
        }
        .padding(.horizontal)
    }
}

#Preview {
    DortmundCourtView(city: "Berlin")
}
