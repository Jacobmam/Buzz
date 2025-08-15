//
//  RankingBoardViewModel.swift
//  Buzz
//
//  Created by Jay Borania on 13/08/25.
//

import Foundation

class RankingBoardViewModel: ObservableObject {
    
    @Published var arrUsers: [User] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    
    private var db = Firestore.firestore()
    private var lastUser: DocumentSnapshot?
    private let pageSize = 10
    private var isFetching = false
    var canLoadMore = true
    
    init() { }
    
    func fetchUsers() {
        guard !isFetching else { return }
        isFetching = true
        isLoading = true
        
        var query: Query = db.collection("users")

        query = query
            .whereField("ranking", isGreaterThan: 0)
            .order(by: "ranking", descending: false)
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

        query = query
            .order(by: "ranking", descending: false)
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
                    self.arrUsers.append(contentsOf: fetchedUsers)
                    self.lastUser = documents.last
                    self.canLoadMore = fetchedUsers.count == self.pageSize
                }
            }
    }
}
