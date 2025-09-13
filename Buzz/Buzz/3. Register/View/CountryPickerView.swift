//
//  CountryPickerView.swift
//  Buzz
//
//  Created by Jay Borania on 20/08/25.
//

import SwiftUI

struct CountryPickerView: View {
    @Environment(\.dismiss) private var dismiss
    var arrCountries: [Country]
    var onSelectCountry: ((Country?) -> Void)
    @State private var selectedCountry: Country?
    @State private var searchText: String = ""
    
    var arrFilteredCountries: [Country] {
        if searchText.isEmpty {
            return arrCountries
        } else {
            return arrCountries.filter { country in
                country.name.lowercased().contains(searchText.lowercased()) ||
                country.dial_code.contains(searchText)
            }
        }
    }
    
    var body: some View {
    
        VStack(alignment: .leading) {
            HStack {
                Text("Select your country!")
                    .font(.system(size: 26, weight: .bold))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Button {
                    onSelectCountry(selectedCountry)
                    dismiss()
                } label: {
                    Image(systemName: "checkmark.square.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.orange)
                        .frame(height: 26)
                }
                .frame(width: 50, height: 50)
            }
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white.opacity(0.4))
                TextField("Search for a country", text: $searchText)
                    .showClearButton($searchText)
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(lineWidth: 0.5)
            }
            .cornerRadius(10)
            .padding(.bottom)
            ScrollView {
            ForEach(arrFilteredCountries) { country in
                VStack(alignment: .leading) {
                    Button {
                        selectedCountry = country
                    } label: {
                        HStack {
                            Text("\(country.flag)  \(country.name)")
                                .font(.system(size: 24,
                                              weight: (selectedCountry == country) ? .semibold : .regular))
                                .foregroundStyle((selectedCountry == country) ? .black : .white)
                            
                            Spacer()
                            
                            Text("\(country.dial_code)")
                                .font(.system(size: 24, weight: (selectedCountry == country) ? .regular : .light))
                                .foregroundStyle((selectedCountry == country) ? .black : .white.opacity(0.8))
                        }
                    }
                    .padding((selectedCountry == country) ? 10 : 4)
                    .background((selectedCountry == country) ? .white : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Divider()
                }
                
            }
        }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    CountryPickerView(arrCountries: [Country(name: "India", dial_code: "+91", code: "IN"),
                                     Country(name: "Germany", dial_code: "+49", code: "DE"),
                                     Country(name: "United States", dial_code: "+1", code: "US")],
                      onSelectCountry: { _ in })
}
