//
//  UserViewController.swift
//  Buzz
//
//  Created by Harshil Gajjar on 01/08/25.
//

import SwiftUI
import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var arrUsers: [User] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    
    var timerSearchValidation: Timer!
    @Published var searchText: String = "" {
        didSet {
            if timerSearchValidation != nil {
                timerSearchValidation.invalidate()
            }
            timerSearchValidation = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(validateSearch), userInfo: nil, repeats: false)
        }
    }
    @Published var currentUserId: String = ""
    @Published var opponentUser: User?
    
    private var db = Firestore.firestore()
    private var lastUser: DocumentSnapshot?
    private let pageSize = 10
    private var isFetching = false
    var canLoadMore = true
    
    init(){}
    
    @objc func validateSearch() {
        guard searchText.count > 2 || searchText.count == 0 else { return }
        fetchUsers()
    }
    
    func fetchUsers() {
        guard !isFetching else { return }
        isFetching = true
        isLoading = true
        
        var query: Query = db.collection("users")

        if !searchText.isEmpty {
            query = query
                .order(by: "username")
                .start(at: [searchText])
                .end(at: [searchText])
        } else {
            query = query
                .order(by: "id")
        }

        query = query
            .limit(to: pageSize)

        query.getDocuments { snapshot, error in
            DispatchQueue.main.async {
                self.isFetching = false
                self.isLoading = false
                
                if let error = error {
                    self.error = "Error fetching users: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let fetchedUsers = documents
                    .compactMap { try? $0.data(as: User.self) }
                    .filter { $0.id != self.currentUserId }
                self.arrUsers = fetchedUsers
                self.lastUser = documents.last
                self.canLoadMore = fetchedUsers.count == self.pageSize
            }
        }
    }

    func loadMoreUsers() {
        guard !isFetching, canLoadMore, let lastUser = lastUser else { return }
        
        isFetching = true
        isLoading = true
        
        var query: Query = db.collection("users")

        if !searchText.isEmpty {
            query = query
                .order(by: "username")
                .start(at: [searchText])
                .end(at: [searchText])
        } else {
            query = query
                .order(by: "id")
        }

        query = query
            .start(afterDocument: lastUser)
            .limit(to: pageSize)

        query.getDocuments { snapshot, error in
                DispatchQueue.main.async {
                    self.isFetching = false
                    self.isLoading = false
                    
                    if let error = error {
                        self.error = "Error loading more users: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let documents = snapshot?.documents else { return }
                    
                    let fetchedUsers = documents
                        .compactMap { try? $0.data(as: User.self) }
                        .filter { $0.id != self.currentUserId }
                    self.arrUsers.append(contentsOf: fetchedUsers)
                    self.lastUser = documents.last
                    self.canLoadMore = fetchedUsers.count == self.pageSize
                }
            }
    }
}
