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
    
    //MARK: Trakt API
    
    func getMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        if let traktApiKey = readTraktAPIKey(), let tmdbApiKey = readTMDBAPIKey() {
            
            let headers = [
                "trakt-api-version": "2",
                "trakt-api-key": traktApiKey
            ]
            
            let urlString = "https://api.trakt.tv/movies/trending?extended=full&page=\(page)&limit=20"
            
            guard let url = URL(string: urlString) else {
                completion(.failure(URLError(.badURL)))
                print("Error: Bad URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                
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
                    let movies = try JSONDecoder().decode([MovieResponse].self, from: data)
 
                    let dispatchGroup = DispatchGroup()
                    var moviesWithPosters: [Movie] = []
                    var requestError: Error?
                    
                    for movie in movies {
                        dispatchGroup.enter()
                        
                        self?.getPosterURLString(for: movie.movie.ids.tmdb, apiKey: tmdbApiKey) { result in
                            
                            guard let self = self else { return }
                            
                            switch result {
                            case .success(let posterURL):
                                let movieWithPoster = Movie(movie: movie, posterURLString: posterURL)
                                moviesWithPosters.append(movieWithPoster)
                            case .failure(let error):
                                requestError = error
                            }
                            dispatchGroup.leave()
                        }
                    }
                    
                    dispatchGroup.notify(queue: .main) {
                        if let error = requestError {
                            completion(.failure(error))
                        } else {
                            completion(.success(moviesWithPosters))
                        }
                    }
                    
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
    
    
    private func readTraktAPIKey() -> String? {
        
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            if let plist = NSDictionary(contentsOfFile: path) as? [String: Any] {
                return plist["TRAKT_API_KEY"] as? String
            }
        }
        return nil
    }
    
    //MARK: TMDB API
    
    private func getPosterURLString(for id: Int, apiKey: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        let urlString = "https://api.themoviedb.org/3/movie/\(id)/images?api_key=\(apiKey)&include_image_language=en"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            print("Error: Bad URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                print("Error fetching poster: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.dataNotAllowed)))
                print("No data received")
                return
            }
            
            do {
                let tmdbResponse = try JSONDecoder().decode(TMDBResponse.self, from: data)
                completion(.success("https://image.tmdb.org/t/p/original" + (tmdbResponse.posters.first?.file_path ?? "")))
            } catch {
                print("Error decoding poster: \(error.localizedDescription)")
                completion(.failure(URLError(.cannotDecodeRawData)))
            }
        }
        task.resume()
    }
    
    
    private func readTMDBAPIKey() -> String? {
        
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
            if let plist = NSDictionary(contentsOfFile: path) as? [String: Any] {
                return plist["TMDB_API_KEY"] as? String
            }
        }
        return nil
    }
}
