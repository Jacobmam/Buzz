//
//  CountryView.swift
//  Buzz
//
//  Created by Jacob Mampuya on 04.03.25.
//

import SwiftUI

struct DeutschlandCourtView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("DEUTSCHLAND 🇩🇪")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.orange)
                    .padding()

                Divider()
                    .background(Color.orange)
                    .padding(.horizontal)

                VStack(spacing: 20) {
                    NavigationLink(destination: BerlinCourtView(city: "Berlin").navigationBarHidden(true)) {
                        CourtButton(title: "BERLIN COURTS")
                    }
                    
                    NavigationLink(destination: DüsseldorfCourtView(city: "Düsseldorf").navigationBarHidden(true)) {
                        CourtButton(title: "DÜSSELDORF COURTS")
                    }
                    
                    NavigationLink(destination: HamburgCourtView(city: "Hamburg").navigationBarHidden(true)) {
                        CourtButton(title: "HAMBURG COURTS")
                    }
                    
                    NavigationLink(destination: MünchenCourtView(city: "München").navigationBarHidden(true)) {
                        CourtButton(title: "MÜNCHEN COURTS")
                    }
                    
                    NavigationLink(destination: DortmundCourtView(city: "Dortmund").navigationBarHidden(true)) {
                        CourtButton(title: "DORTMUND COURTS")
                    }
                    
                    NavigationLink(destination: KölnCourtView(city: "Köln").navigationBarHidden(true)) {
                        CourtButton(title: "KÖLN COURTS")
                    }
                    
                    NavigationLink(destination: FrankfurtCourtView(city: "Frankfurt").navigationBarHidden(true)) {
                        CourtButton(title: "FRANKFURT COURTS")
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .navigationBarHidden(true)
    }
}

struct CourtButton: View {
    var title: String

    var body: some View {
        Text(title)
            .font(.title2)
            .bold()
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color.orange.opacity(0.8))) // Dunkleres Orange
            .padding(.horizontal)
    }
}

#Preview {
    DeutschlandCourtView()
}
