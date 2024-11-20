//
//  AuthManager.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 31.10.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class AuthManager {
    
    static let shared = AuthManager()
    
    private init() {}
    
    public func registerUser(username: String, email: String, password: String, completion: @escaping (Bool, Error?)->Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error {
                completion(false, error)
                return
            }
            
            guard let resultUser = result?.user else {
                completion(false, nil)
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users")
                .document(resultUser.uid)
                .setData([
                    "username": username,
                    "email": email
                ]) { error in
                    if let error {
                        completion(false, error)
                        return
                    }
                    completion(true, nil)
                }
        }
    }
    
    public func signIn(email: String, password: String, completion: @escaping (Error?)->Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error {
                completion(error)
                return
            } else {
                completion(nil)
            }
        }
    }
    
    public func signOut(completion: @escaping (Error?)->Void) {
        do {
            try Auth.auth().signOut()
            completion(nil)
        } catch let error {
            completion(error)
        }
    }
    
    public func forgotPassword(email: String, completion: @escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            completion(error)
        }
    }
    
    public func fetchUser(with userUID: String, completion: @escaping (User?, Error?) -> Void) {
        
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userUID)
            .getDocument { snapshot, error in
                if let error {
                    completion(nil, error)
                    return
                }
                
                if let snapshot,
                   let snapshotData = snapshot.data(),
                   let username = snapshotData["username"] as? String,
                   let likedMovies = snapshotData["likedMovies"] as? [Int] {
                    let user = User(username: username, userUID: userUID, likedMovies: likedMovies)
                    completion(user, nil)
                }
                
            }
    }
    
    func fetchAllUsers(completion: @escaping ([User]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("users").getDocuments { snapshot, error in
            if let error {
                completion([], error)
                return
            }

            let currentUserUID = Auth.auth().currentUser?.uid ?? ""
            
            if let snapshot {
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
    }
}
