//
//  CourtRepository.swift
//  Buzz
//
//  Created by Jacob Mampuya on 07.03.25.
//

import Foundation

class CourtRepository {
    private let baseURL = "http://127.0.0.1:8080/courts"
    
    func fetchCourts(completion: @escaping (Result<[Court], Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No Data", code: 0)))
                return
            }
            
            do {
                let courts = try JSONDecoder().decode([Court].self, from: data)
                completion(.success(courts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
