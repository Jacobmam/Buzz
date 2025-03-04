//
//  CountryView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 04.03.25.
//

import SwiftUI

struct CourtCountryView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Deutschland")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.orange)
                    .padding()

                Divider()
                    .background(Color.orange)
                    .padding(.horizontal)

                VStack(spacing: 20) {
                    NavigationLink(destination: BerlinCourtView(city: "Berlin").navigationBarHidden(true)) {
                        Text("BERLIN COURTS")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange))
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    CourtCountryView()
}
