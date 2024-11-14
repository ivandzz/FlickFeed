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
    let backdropURLString: String
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

//MARK: - Mock data
struct MovieMockData {
    static let sampleMovie = Movie(movieInfo: MovieDetails(title: "My Fault", year: 2023, ids: MovieIDs(tmdb: 1010581), tagline: nil, overview: "Noah must leave her city, boyfriend, and friends to move into William Leister's mansion, the flashy and wealthy husband of her mother Rafaela. As a proud and independent 17 year old, Noah resists living in a mansion surrounded by luxury. However, it is there where she meets Nick, her new stepbrother, and the clash of their strong personalities becomes evident from the very beginning.", runtime: 117, trailer: "https://youtube.com/watch?v=xY-qRGC6Yu0", rating: 7.03, genres: ["romance", "drama"], certification: nil), posterURLString: "https://image.tmdb.org/t/p/original/lntyt4OVDbcxA1l7LtwITbrD3FI.jpg", backdropURLString: "https://image.tmdb.org/t/p/original/pNOccytgkGuyofTLmh1sqEfTJuE.jpg")
}
