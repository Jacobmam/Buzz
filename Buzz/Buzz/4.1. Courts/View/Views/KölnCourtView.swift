//
//  KölnCourtView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 07.03.25.
//

import SwiftUI

struct KölnCourtView: View {
    var city: String
    @Environment(\.presentationMode) var presentationMode
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
                                CourtItemView5(
                                    name: court.name,
                                    imageUrl: court.imageUrl,
                                    rating: 4.0,
                                    reviews: 100,
                                    address: court.address
                                )
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


struct CourtItemView5: View {
    var name: String
    var imageUrl: String
    var rating: Double
    var reviews: Int
    var address: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .padding(.vertical, 5)

            AsyncImage(url: URL(string: imageUrl)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(10)

            HStack {
                Text("\(rating, specifier: "%.1f") ⭐️")
                Text("(\(reviews) Rezensionen)")
                Spacer()
            }
            .foregroundColor(.white.opacity(0.8))
            .padding(.vertical, 5)

            Text(address)
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 10)

            Divider()
                .background(Color.orange.opacity(0.5))
        }
        .padding(.horizontal)
    }
}

#Preview {
    KölnCourtView(city: "Köln")
}
