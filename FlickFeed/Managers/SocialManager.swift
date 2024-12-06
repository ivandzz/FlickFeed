//
//  SocialManager.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 14.11.2024.
//

import FirebaseAuth
import FirebaseFirestore

final class SocialManager {
    
    static let shared = SocialManager()
    
    private init() {}
    
    public func updateLike(for movieId: Int?, completion: @escaping (Error?) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        guard let movieId else { return }
        
        let db = Firestore.firestore()
        let likesRef = db.collection("users").document(currentUserUID)
        
        likesRef.getDocument { (document, error) in
            if let error {
                completion(error)
                return
            }
            
            var likedMovies = document?.data()?["likedMovies"] as? [Int] ?? []
            
            if let index = likedMovies.firstIndex(of: movieId) {
                likedMovies.remove(at: index)
                CoreDataManager.shared.deleteMovies(with: [movieId])
            } else {
                likedMovies.append(movieId)
                CoreDataManager.shared.addMovie(with: movieId)
            }
            
            likesRef.setData(["likedMovies": likedMovies], merge: true) { error in
                if let error {
                    completion(error)
                }
            }
        }
    }
    
    public func checkIfLiked(movieId: Int?, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        guard let movieId else { return }
        
        let db = Firestore.firestore()
        let likesRef = db.collection("users").document(currentUserUID)
        
        likesRef.getDocument { (document, error) in
            if let error {
                completion(.failure(error))
                return
            }
            
            let likedMovies = document?.data()?["likedMovies"] as? [Int] ?? []
            completion(.success(likedMovies.contains(movieId)))
        }
    }
    
    public func updateFriend(for userUID: String?, completion: @escaping (Error?) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        guard let userUID else { return }
        
        let db = Firestore.firestore()
        let friendsRef = db.collection("users").document(currentUserUID)
        
        friendsRef.getDocument { (document, error) in
            if let error {
                completion(error)
                return
            }
            
            var friends = document?.data()?["friends"] as? [String] ?? []
            
            if let index = friends.firstIndex(of: userUID) {
                friends.remove(at: index)
            } else {
                friends.append(userUID)
            }
            
            friendsRef.setData(["friends": friends], merge: true) { error in
                if let error {
                    completion(error)
                }
            }
        }
    }
    
    public func checkIfFriend(friendUID: String?, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        guard let friendUID else { return }
        
        let db = Firestore.firestore()
        let likesRef = db.collection("users").document(currentUserUID)
        
        likesRef.getDocument { (document, error) in
            if let error {
                completion(.failure(error))
                return
            }
            
            let friends = document?.data()?["friends"] as? [String] ?? []
            completion(.success(friends.contains(friendUID)))
        }
    }
}
