//
//  Courts.swift
//  Buzz
//
//  Created by Jacob Mampuya on 07.03.25.
//

import Foundation

struct Court: Codable, Identifiable {
    let id = UUID().uuidString
    let name: String
    let address: String
    let city: String
    let postalCode: String?
    let imageUrl: String
    let latitude: Double
    let longitude: Double
}
