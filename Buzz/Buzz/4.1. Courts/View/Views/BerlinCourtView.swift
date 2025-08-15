//
//  CityCourtView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 04.03.25.
//

import SwiftUI

struct BerlinCourtView: View {
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
                                CourtItemView(court: court)
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

struct CourtItemView: View {
    @State private var showAlert = false
    var court: Court

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
                    showAlert = true
                }) {
                    Text("Hinzufügen")
                }
                .buttonStyle(.bordered)
                .foregroundColor(.orange)
                .alert("Erfolgreich Hinzugefügt", isPresented: $showAlert) {
                    Button("OK", role: .cancel) { }
                }
            }
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
    BerlinCourtView(city: "Berlin")
}
