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

    var body: some View {
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

            ScrollView {
                CourtItemView(name: "GNEISE", imageName: "court1", rating: 4.3, reviews: 26, address: "Schleiermacherstraße 18")
                CourtItemView(name: "JAHN-SPORTPARK", imageName: "court2", rating: 4.2, reviews: 3592, address: "Sportanlage in Berlin, Deutschland")
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct CourtItemView: View {
    var name: String
    var imageName: String
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

            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
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
    BerlinCourtView(city: "Berlin")
}
