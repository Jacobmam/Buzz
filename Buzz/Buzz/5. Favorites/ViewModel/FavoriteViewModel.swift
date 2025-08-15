//
//  FavoriteViewModel.swift
//  Buzz
//
//  Created by Jacob Mampuya on 19.03.25.
//

import Foundation
import Observation

class FavoriteViewModel: ObservableObject {
    var favoriteCourts: [Court] = []
    private let database = Firestore.firestore()
    
    init() {
        Task {
            try await getFavorites()
        }
    }
    
    func addCourt(court: Court) {
        guard let user = Auth.auth().currentUser else { return }
        let courtRef = database.collection("users").document(user.uid).collection("favorites").document(court.id)
        
        do {
            try courtRef.setData(from: court)
            print("Court erfolgreich hinzugefügt: \(court.id)")
            Task {
                try await getFavorites()
            }
        } catch {
            print("Fehler beim Hinzufügen: \(error.localizedDescription)")
        }
    }
    
    func getFavorites() async throws {
        guard let user = Auth.auth().currentUser else { return }
        let favoritesRef = database.collection("users").document(user.uid).collection("favorites")
        
        do {
            let snapshot = try await favoritesRef.getDocuments()
            self.favoriteCourts = snapshot.documents.compactMap { document in
                try? document.data(as: Court.self)
            }
            print("Favoriten erfolgreich geladen: \(favoriteCourts.count) Einträge")
        } catch {
            print("Fehler beim Laden der Favoriten: \(error.localizedDescription)")
        }
    }
    
    func delete(courtID: String) async {
        guard let user = Auth.auth().currentUser else { return }
        let courtRef = database.collection("users").document(user.uid).collection("favorites").document(courtID)
        
        do {
            let document = try await courtRef.getDocument()
            if document.exists {
                try await courtRef.delete()
                print("Court erfolgreich gelöscht: \(courtID)")
                try await getFavorites()
            } else {
                print("Court nicht gefunden: \(courtID)")
            }
        } catch {
            print("Fehler beim Löschen: \(error.localizedDescription)")
        }
    }
}
