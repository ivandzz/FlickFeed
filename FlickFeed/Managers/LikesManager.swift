//
//  LikesManager.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 14.11.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

final class LikesManager {
    
    static let shared = LikesManager()
    
    private init() {}
    
    func updateLike(for movieId: Int?, completion: @escaping (Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let movieId = movieId else { return }
        
        let db = Firestore.firestore()
        let likesRef = db.collection("users").document(userId)
        
        likesRef.getDocument { (document, error) in
            if let error = error {
                completion(error)
                return
            }
            
            var likedMovies = document?.data()?["likedMovies"] as? [Int] ?? []
            
            if let index = likedMovies.firstIndex(of: movieId) {
                likedMovies.remove(at: index)
            } else {
                likedMovies.append(movieId)
            }
            
            likesRef.setData(["likedMovies": likedMovies], merge: true) { error in
                if let error = error {
                    completion(error)
                }
            }
        }
    }
    
    func isLiked(movieId: Int?, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let movieId = movieId else { return }
        
        let db = Firestore.firestore()
        let likesRef = db.collection("users").document(userId)
        
        likesRef.getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let likedMovies = document?.data()?["likedMovies"] as? [Int] ?? []
            completion(.success(likedMovies.contains(movieId)))
        }
        
    }
}
