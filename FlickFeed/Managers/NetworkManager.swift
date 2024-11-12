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
    
    // MARK: - Public Methods
    func getMovies(page: Int, completion: @escaping (Result<[Movie], Error>) -> Void) {
        let urlString = "https://api.trakt.tv/movies/trending?extended=full&page=\(page)&limit=20"
        fetchMovies(from: urlString, completion: completion)
    }
    
    func getLikedMovies(with ids: [Int], completion: @escaping (Result<[Movie], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var likedMovies: [Movie] = []
        var requestError: Error?
        
        for id in ids {
            dispatchGroup.enter()
            let urlString = "https://api.trakt.tv/search/tmdb/\(id)?type=movie&extended=full"
            fetchMovies(from: urlString) { result in
                switch result {
                case .success(let movies):
                    if let movie = movies.first {
                        likedMovies.append(movie)
                    }
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
                completion(.success(likedMovies))
            }
        }
    }
    
    // MARK: - Private Methods
    private func fetchMovies(from urlString: String, completion: @escaping (Result<[Movie], Error>) -> Void) {
        guard let traktApiKey = readAPIKey(for: "TRAKT_API_KEY") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let headers = [
            "trakt-api-version": "2",
            "trakt-api-key": traktApiKey
        ]
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
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
                let movieResponses = try JSONDecoder().decode([MovieResponse].self, from: data)
                self.fetchImages(for: movieResponses) { result in
                    completion(result)
                }
            } catch {
                completion(.failure(URLError(.cannotDecodeRawData)))
            }
        }
        task.resume()
    }
    
    private func fetchImages(for movieResponses: [MovieResponse], completion: @escaping (Result<[Movie], Error>) -> Void) {
        let dispatchGroup = DispatchGroup()
        var moviesWithPosters: [Movie] = []
        var requestError: Error?
        
        for movieResponse in movieResponses {
            dispatchGroup.enter()
            getImagesURLString(for: movieResponse.movie.ids.tmdb) { result in
                switch result {
                case .success((let posterURL, let backdropURL)):
                    let movie = Movie(movieInfo: movieResponse.movie, posterURLString: posterURL, backdropURLString: backdropURL)
                    moviesWithPosters.append(movie)
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
    }
    
    private func getImagesURLString(for id: Int, completion: @escaping (Result<(String, String), Error>) -> Void) {
        guard let tmdbApiKey = readAPIKey(for: "TMDB_API_KEY") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let urlString = "https://api.themoviedb.org/3/movie/\(id)/images?api_key=\(tmdbApiKey)&include_image_language=en"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            
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
                let posterPath = tmdbResponse.posters.first?.file_path ?? ""
                let backdropPath = tmdbResponse.backdrops.first?.file_path ?? ""
                completion(.success(("https://image.tmdb.org/t/p/original\(posterPath)" , "https://image.tmdb.org/t/p/original\(backdropPath)")))
            } catch {
                completion(.failure(URLError(.cannotDecodeRawData)))
            }
        }
        task.resume()
    }
    
    private func readAPIKey(for key: String) -> String? {
        guard
            let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
            let apiKey = plist[key] as? String
        else {
            return nil
        }
        return apiKey
    }
}
