//
//  FirebaseCommonClass.swift
//  Buzz
//
//  Created by Jay Borania on 16/02/26.
//

//import Foundation
//import FirebaseFirestore
//
//class FirebaseCommonClass: ObservableObject {
//    private let db = Firestore.firestore()
//    @Published var authentication: String = "authentication"
//
//    @Published var isWhatsAppAuthEnabled: Bool = false
//    
//    func fetchSettings() {
//        db.collection("settings").document(authentication).getDocument { (document, error) in
//            if let data = document?.data() {
//                print("fetchSettings: \(data)")
//                self.isWhatsAppAuthEnabled = data["isWhatsAppAuthEnabled"] as? Bool ?? false
//                print(self.isWhatsAppAuthEnabled)
//            }
//            if let error = error { print(" error: \(error)"); }
//        }
//    }
//}
import Foundation
import FirebaseFirestore

class FirebaseCommonClass: ObservableObject {
    
    private let db = Firestore.firestore()
    
    // No need to publish this — it's constant
    private let settingsDocumentID = "authentication"
    
    @Published var isSMSAuthEnabled: Bool = false
    
    func fetchSettings() {
        db.collection("settings")
            .document(settingsDocumentID)
            .getDocument { [weak self] (document, error) in
                
                guard let self = self else { return }
                
                if let error = error {
                    print("Firestore Error:", error.localizedDescription)
                    return
                }
                
                guard let document = document, document.exists else {
                    print("Document does not exist")
                    return
                }
                
                if let data = document.data() {
                    print("Fetched Data:", data)
                    
                    // Always update Published properties on main thread
                    DispatchQueue.main.async {
                        self.isSMSAuthEnabled =
                            data["isSMSAuthEnabled"] as? Bool ?? false
                        print(self.isSMSAuthEnabled)
                    }
                }
            }
    }
}
