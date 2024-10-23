//
//  NetworkManager.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 23/10/24.
//

import Foundation

//TODO: Error handling

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    func getMovies(page: Int, completion: @escaping (Result<MovieResponse, Error>) -> Void) {

        if let apiKey = readAPIKey() {
            let urlString = "https://api.themoviedb.org/3/movie/popular?page=\(page)&api_key=\(apiKey)"
            
            guard let url = URL(string: urlString) else {
                completion(.failure(URLError(.badURL)))
                print("Error: Bad URL")
                return
            }
            
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                
                if let error = error {
                    completion(.failure(error))
                    print("Error fetching movies: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    completion(.failure(URLError(.dataNotAllowed)))
                    print("No data received")
                    return
                }
                
                do {
                    let movieResponse = try JSONDecoder().decode(MovieResponse.self, from: data)
                    completion(.success(movieResponse))
                } catch {
                    print("Error decoding movies: \(error.localizedDescription)")
                    completion(.failure(URLError(.cannotDecodeRawData)))
                }
            }
            
            task.resume()
        } else {
            print("Error: API key not found")
        }
    }
    
    private func readAPIKey() -> String? {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            if let plist = NSDictionary(contentsOfFile: path) as? [String: Any] {
                return plist["API_KEY"] as? String
            }
        }
        return nil
    }
    
}
