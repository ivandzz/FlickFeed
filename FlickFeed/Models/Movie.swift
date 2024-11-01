//
//  Movie.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 23/10/24.
//

import Foundation

struct Movie {
    let movieInfo: MovieDetails
    let posterURLString: String
}

//MARK: Trakt API

struct MovieResponse: Decodable {
    let movie: MovieDetails
}

struct MovieDetails: Decodable {
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

struct MovieIDs: Decodable {
    let tmdb: Int
}

//MARK: TMDB API

struct TMDBResponse: Decodable {
    let posters: [Image]
}

struct Image: Decodable {
    let file_path: String
}
