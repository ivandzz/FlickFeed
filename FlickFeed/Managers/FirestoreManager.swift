//
//  FirestoreManager.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 21.11.2024.
//

import FirebaseFirestore
import FirebaseAuth

final class FirestoreManager {
    
    private let db = Firestore.firestore()
    
    private var lastAllUsersSnapshot: DocumentSnapshot?
    private var lastSearchUsersSnapshot: DocumentSnapshot?
    private var isLoading = false
    
    public func fetchAllUsers(completion: @escaping ([User]?, Error?) -> Void) {
        guard !isLoading else { return }
        isLoading = true
        
        var query = db.collection("users")
            .order(by: "username", descending: true)
            .limit(to: 20)
        
        if let lastSnapshot = lastAllUsersSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self else { return }
            
            self.isLoading = false
            
            if let error {
                completion([], error)
                return
            }
            
            guard let snapshot else {
                completion([], nil)
                return
            }
            
            if let lastSnapshot = snapshot.documents.last {
                self.lastAllUsersSnapshot = lastSnapshot
            }
            
            let currentUserUID = Auth.auth().currentUser?.uid ?? ""
            
            var users: [User] = []
            
            for document in snapshot.documents {
                let snapshotData = document.data()
                let userUID = document.documentID
                
                if userUID == currentUserUID { continue }
                
                if let username = snapshotData["username"] as? String,
                   let likedMovies = snapshotData["likedMovies"] as? [Int] {
                    let user = User(username: username, userUID: userUID, likedMovies: likedMovies)
                    users.append(user)
                }
            }
            
            completion(users, nil)
        }
    }
    
    public func searchUsers(_ searchText: String, resetPagination: Bool = false, completion: @escaping ([User]?, Error?) -> Void) {
        guard !isLoading else { return }
        isLoading = true

        guard !searchText.isEmpty else {
            isLoading = false
            completion([], nil)
            return
        }

        if resetPagination {
            lastSearchUsersSnapshot = nil
        }

        var query = db.collection("users")
            .order(by: "username", descending: true)
            .whereField("username", isGreaterThanOrEqualTo: searchText)
            .whereField("username", isLessThanOrEqualTo: searchText + "\u{f8ff}")
            .limit(to: 20)

        if let lastSnapshot = lastSearchUsersSnapshot {
            query = query.start(afterDocument: lastSnapshot)
        }

        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }

            self.isLoading = false

            if let error {
                completion([], error)
                return
            }

            guard let snapshot else {
                completion([], nil)
                return
            }

            if let lastSnapshot = snapshot.documents.last {
                self.lastSearchUsersSnapshot = lastSnapshot
            }

            let currentUserUID = Auth.auth().currentUser?.uid ?? ""
            var users: [User] = []

            for document in snapshot.documents {
                let snapshotData = document.data()
                let userUID = document.documentID

                if userUID == currentUserUID { continue }

                if let username = snapshotData["username"] as? String,
                   let likedMovies = snapshotData["likedMovies"] as? [Int] {
                    let user = User(username: username, userUID: userUID, likedMovies: likedMovies)
                    users.append(user)
                }
            }

            completion(users, nil)
        }
    }
    
    public func resetAllUsersPagination() {
        lastAllUsersSnapshot = nil
    }
    
    public func resetSearchUsersPagination() {
        lastSearchUsersSnapshot = nil
    }
}
