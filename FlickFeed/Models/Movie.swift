//
//  Movie.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 23/10/24.
//

import Foundation

struct Movie: Decodable {
    
    let id: Int
    let title: String
    let overview: String
    let poster_path: String
    let backdrop_path: String
    let release_date: String
    let vote_average: Double
    let genre_ids: [Int]
}

struct MovieResponse: Decodable {
    
    let results: [Movie]
    let total_pages: Int
}
