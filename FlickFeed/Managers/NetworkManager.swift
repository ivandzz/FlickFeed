//
//  NetworkManager.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 23/10/24.
//

import Foundation

final class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    //MARK: Trakt API
    func getMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let traktApiKey = readTraktAPIKey(), let tmdbApiKey = readTMDBAPIKey() else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let headers = [
            "trakt-api-version": "2",
            "trakt-api-key": traktApiKey
        ]
        
        let urlString = "https://api.trakt.tv/movies/trending?extended=full&page=\(page)&limit=20"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.dataNotAllowed)))
                return
            }
            
            do {
                let movies = try JSONDecoder().decode([MovieResponse].self, from: data)
                
                let dispatchGroup = DispatchGroup()
                var moviesWithPosters: [Movie] = []
                var requestError: Error?
                
                for movie in movies {
                    dispatchGroup.enter()
                    
                    self.getPosterURLString(for: movie.movie.ids.tmdb, apiKey: tmdbApiKey) { [weak self] result in
                        guard self != nil else { return }
                        
                        switch result {
                        case .success(let posterURL):
                            let movieWithPoster = Movie(movieInfo: movie.movie, posterURLString: posterURL)
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
                completion(.failure(URLError(.cannotDecodeRawData)))
            }
        }
        task.resume()
    }
    
    func getLikedMovies(with ids: [Int], completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let traktApiKey = readTraktAPIKey(), let tmdbApiKey = readTMDBAPIKey() else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var likedMovies: [Movie] = []
        var requestError: Error?
        let dispatchGroup = DispatchGroup()
        
        let headers = [
            "trakt-api-version": "2",
            "trakt-api-key": traktApiKey
        ]
        
        for id in ids {
            dispatchGroup.enter()
            let urlString = "https://api.trakt.tv/search/tmdb/\(id)?type=movie&extended=full"
            
            guard let url = URL(string: urlString) else {
                completion(.failure(URLError(.badURL)))
                dispatchGroup.leave()
                continue
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = headers
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    requestError = error
                    dispatchGroup.leave()  // Leave the group on error
                    return
                }
                
                guard let data = data else {
                    requestError = URLError(.dataNotAllowed)
                    dispatchGroup.leave()  // Leave the group if data is nil
                    return
                }
                
                do {
                    let movies = try JSONDecoder().decode([MovieResponse].self, from: data)
                    
                    if let movie = movies.first {
                        self.getPosterURLString(for: movie.movie.ids.tmdb, apiKey: tmdbApiKey) { result in
                            switch result {
                            case .success(let posterURL):
                                let movieWithPoster = Movie(movieInfo: movie.movie, posterURLString: posterURL)
                                likedMovies.append(movieWithPoster)
                            case .failure(let error):
                                requestError = error
                            }
                            dispatchGroup.leave()  // Ensure leave is called here
                        }
                    } else {
                        dispatchGroup.leave()  // Leave if no movies found
                    }
                } catch {
                    requestError = URLError(.cannotDecodeRawData)
                    dispatchGroup.leave()  // Leave on decode error
                }
            }
            task.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            if let error = requestError {
                completion(.failure(error))
            } else {
                completion(.success(likedMovies))
            }
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
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard self != nil else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.dataNotAllowed)))
                return
            }
            
            do {
                let tmdbResponse = try JSONDecoder().decode(TMDBResponse.self, from: data)
                completion(.success("https://image.tmdb.org/t/p/original" + (tmdbResponse.posters.first?.file_path ?? "")))
            } catch {
                completion(.failure(URLError(.cannotDecodeRawData)))
            }
        }
        task.resume()
    }
    
    func getBackdropURLString(for id: Int, completion: @escaping (Result<String, Error>) -> Void) {
        guard let apiKey = readTMDBAPIKey() else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let urlString = "https://api.themoviedb.org/3/movie/\(id)/images?api_key=\(apiKey)&include_image_language=en"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard self != nil else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.dataNotAllowed)))
                return
            }
            
            do {
                let tmdbResponse = try JSONDecoder().decode(TMDBResponse.self, from: data)
                completion(.success("https://image.tmdb.org/t/p/original" + (tmdbResponse.backdrops.first?.file_path ?? "")))
            } catch {
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
