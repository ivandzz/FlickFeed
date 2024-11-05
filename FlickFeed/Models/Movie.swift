//
//  Movie.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 23/10/24.
//

import Foundation

struct Movie: Codable {
    let movieInfo: MovieDetails
    let posterURLString: String
}

//MARK: Trakt API
struct MovieResponse: Decodable {
    let movie: MovieDetails
}

struct MovieDetails: Codable {
    let title: String
    let year: Int?
    let ids: MovieIDs
    let tagline: String?
    let overview: String
    let runtime: Int?
    let trailer: String?
    let rating: Double
    let genres: [String]
    let certification: String?
}

struct MovieIDs: Codable {
    let tmdb: Int
}

//MARK: TMDB API
struct TMDBResponse: Decodable {
    let posters: [Image]
    let backdrops: [Image]
}

struct Image: Decodable {
    let file_path: String
}
