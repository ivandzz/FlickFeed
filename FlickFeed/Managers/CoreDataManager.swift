//
//  CoreDataManager.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 15.11.2024.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FlickFeed")
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Fetch Cached Movies
    func fetchCachedMovies(with ids: [Int]) -> [Movie] {
        let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "movieId IN %@", ids.map { NSNumber(value: $0) })
        
        do {
            let entities = try context.fetch(fetchRequest)
            return entities.map { Movie(fromEntity: $0) }
        } catch {
            print("Error fetching cached movies: \(error)")
            return []
        }
    }
    
    // MARK: - Cache Movies
    func cacheMovies(_ movies: [Movie]) {
        persistentContainer.performBackgroundTask { context in
            movies.forEach { movie in
                let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "movieId == %d", movie.movieInfo.ids.tmdb)
                
                let entity = (try? context.fetch(fetchRequest).first) ?? MovieEntity(context: context)
                entity.populate(with: movie)
            }
            
            do {
                try context.save()
            } catch {
                print("Error caching movies: \(error)")
            }
        }
    }
    
    // MARK: - Cache Movie by ID
    func addMovie(with id: Int) {
        persistentContainer.performBackgroundTask { context in
            NetworkManager.shared.getLikedMovies(with: [id]) { result in
                switch result {
                case .success(let movies):
                    guard let movie = movies.first else {
                        print("No movie found for ID: \(id)")
                        return
                    }
                    
                    let fetchRequest: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "movieId == %d", id)
                    
                    do {
                        if let entity = try context.fetch(fetchRequest).first {
                            entity.populate(with: movie)
                            
                            do {
                                try context.save()
                            } catch {
                                print("Error saving updated movie to Core Data: \(error)")
                            }
                        } else {
                            print("Movie with ID \(id) not found in Core Data. No update was made.")
                        }
                    } catch {
                        print("Error fetching movie from Core Data: \(error)")
                    }
                    
                case .failure(let error):
                    print("Error fetching movie details: \(error)")
                }
            }
        }
    }
    
    // MARK: - Delete Movies
    func deleteMovies(with ids: [Int]) {
        persistentContainer.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MovieEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "movieId IN %@", ids.map { NSNumber(value: $0) })
            
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Error deleting cached movies: \(error)")
            }
        }
    }
}

// MARK: - MovieEntity Extension
extension MovieEntity {
    func populate(with movie: Movie) {
        self.movieId = Int64(movie.movieInfo.ids.tmdb)
        self.title = movie.movieInfo.title
        self.year = Int16(movie.movieInfo.year ?? 0)
        self.tagline = movie.movieInfo.tagline
        self.overview = movie.movieInfo.overview
        self.runtime = Int16(movie.movieInfo.runtime ?? 0)
        self.trailer = movie.movieInfo.trailer
        self.rating = movie.movieInfo.rating
        
        let genresArray: [String] = movie.movieInfo.genres.compactMap { "\($0)" }
        if let jsonData = try? JSONSerialization.data(withJSONObject: genresArray, options: []) {
            self.genres = jsonData as Data
        } else {
            self.genres = nil
            print("Error serializing genres array to JSON")
        }
        
        self.certification = movie.movieInfo.certification
        self.posterURLString = movie.posterURLString
        self.backdropURLString = movie.backdropURLString
    }
}

