//
//  PopularFeedDetailsVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 01.11.2024.
//

import UIKit
import YouTubeiOSPlayerHelper

class PopularFeedDetailsVC: UIViewController {
    
    // MARK: - Variables
    let movie: Movie
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font          = .monospacedSystemFont(ofSize: 17, weight: .semibold)
        label.textColor     = .white
        label.numberOfLines = 2
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let voteLabel: UILabel = {
        let label = UILabel()
        label.font          = .monospacedSystemFont(ofSize: 17, weight: .regular)
        label.textColor     = .white
        label.numberOfLines = 1
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let overviewLabel: UILabel = {
        let label = UILabel()
        label.font          = .systemFont(ofSize: 14, weight: .medium)
        label.textColor     = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let playerView: YTPlayerView = {
        let playerView = YTPlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        return playerView
    }()
    
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.font          = .monospacedSystemFont(ofSize: 16, weight: .regular)
        label.textColor     = .white
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let runtimeLabel: UILabel = {
        let label = UILabel()
        label.font          = .monospacedSystemFont(ofSize: 16, weight: .regular)
        label.textColor     = .white
        label.numberOfLines = 1
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genresTitleLabel: UILabel = {
        let label = UILabel()
        label.font          = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        label.textColor     = .white
        label.numberOfLines = 1
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let genresListLabel: UILabel = {
        let label = UILabel()
        label.font          = .systemFont(ofSize: 13, weight: .regular)
        label.textColor     = .white
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingTitleLabel: UILabel = {
        let label = UILabel()
        label.font          = .monospacedSystemFont(ofSize: 14, weight: .semibold)
        label.textColor     = .white
        label.numberOfLines = 1
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font          = .systemFont(ofSize: 14, weight: .regular)
        label.textColor     = .white
        label.numberOfLines = 1
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let taglineLabel: UILabel = {
        let label = UILabel()
        label.font          = .monospacedSystemFont(ofSize: 15, weight: .semibold)
        label.textColor     = .white
        label.numberOfLines = 0
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode   = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderView: UIView = {
        let placeholder      = UIView()
        let placeholderLabel = UILabel()
        
        placeholder.backgroundColor    = .darkGray
        placeholderLabel.text          = "No Trailer Available"
        placeholderLabel.textColor     = .white
        placeholderLabel.textAlignment = .center
        placeholderLabel.font          = .systemFont(ofSize: 16, weight: .semibold)
        
        placeholder.translatesAutoresizingMaskIntoConstraints      = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        placeholder.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholder.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: placeholder.centerYAnchor)
        ])
        
        return placeholder
    }()
    
    // MARK: - Lifecycle
    init(movie: Movie) {
        
        self.movie = movie
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupUI()
        playerView.delegate = self
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        view.backgroundColor = .black
    
        configure()
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(voteLabel)
        scrollView.addSubview(overviewLabel)
        scrollView.addSubview(playerView)
        scrollView.addSubview(yearLabel)
        scrollView.addSubview(runtimeLabel)
        scrollView.addSubview(genresTitleLabel)
        scrollView.addSubview(genresListLabel)
        scrollView.addSubview(ratingTitleLabel)
        scrollView.addSubview(ratingLabel)
        scrollView.addSubview(taglineLabel)
        scrollView.addSubview(imageView)
        
        playerView.addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: voteLabel.leadingAnchor, constant: -10),
            
            voteLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            voteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            voteLabel.widthAnchor.constraint(equalToConstant: 65),
            
            overviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            overviewLabel.bottomAnchor.constraint(equalTo: playerView.topAnchor, constant: -10),
            
            playerView.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 10),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.heightAnchor.constraint(equalToConstant: 230),
            
            yearLabel.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 10),
            yearLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            yearLabel.trailingAnchor.constraint(lessThanOrEqualTo: runtimeLabel.leadingAnchor, constant: -10),
            
            runtimeLabel.topAnchor.constraint(equalTo: yearLabel.topAnchor),
            runtimeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            runtimeLabel.widthAnchor.constraint(equalToConstant: 70),
            
            genresTitleLabel.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 10),
            genresTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            genresTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            genresListLabel.topAnchor.constraint(equalTo: genresTitleLabel.bottomAnchor, constant: 5),
            genresListLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            genresListLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            ratingTitleLabel.topAnchor.constraint(equalTo: genresTitleLabel.topAnchor),
            ratingTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ratingTitleLabel.widthAnchor.constraint(equalToConstant: 61),
            
            ratingLabel.topAnchor.constraint(equalTo: ratingTitleLabel.bottomAnchor, constant: 5),
            ratingLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ratingLabel.widthAnchor.constraint(equalToConstant: 61),
            
            taglineLabel.topAnchor.constraint(equalTo: genresListLabel.bottomAnchor, constant: 10),
            taglineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            taglineLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            imageView.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 230),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
            
            placeholderView.topAnchor.constraint(equalTo: playerView.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor)
        ])
    }
    
    //MARK: - Configuration
    private func configure() {
        titleLabel.text       = movie.movieInfo.title
        voteLabel.text        = "\(movie.movieInfo.rating.rounded(toPlaces: 1))/10"
        overviewLabel.text    = movie.movieInfo.overview
        yearLabel.text        = "Year: \(movie.movieInfo.year.map { "\($0)" } ?? "N/A")"
        runtimeLabel.text     = "\(movie.movieInfo.runtime.map { "\($0) min" } ?? "N/A min")"
        genresListLabel.text  = movie.movieInfo.genres.joined(separator: "\n").capitalized
        ratingTitleLabel.text = "Rating:"
        ratingLabel.text      = movie.movieInfo.certification ?? "N/A"
        taglineLabel.text     = movie.movieInfo.tagline ?? movie.movieInfo.title
        
        if movie.movieInfo.genres.count == 1 {
            genresTitleLabel.text = "Genre:"
        } else {
            genresTitleLabel.text = "Genres:"
        }
        
        if let trailer = movie.movieInfo.trailer,
           let videoID = extractVideoID(from: trailer) {
            playerView.load(withVideoId: videoID)
            placeholderView.isHidden = true
        } else {
            placeholderView.isHidden = false
        }
        
        NetworkManager.shared.getBackdropURLString(for: movie.movieInfo.ids.tmdb) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success(let urlString):
                DispatchQueue.main.async {
                    self.imageView.kf.indicatorType = .activity
                    self.imageView.kf.setImage(with: URL(string: urlString), placeholder: UIImage(named: "placeholderImage"))
                }
            case .failure(let error):
                AlertManager.showBasicAlert(on: self, title: "Something went wrong", message: error.localizedDescription)
            }
        }
    }
    
    //MARK: - Helper Functions
    private func extractVideoID(from url: String) -> String? {
        
        let pattern = "v=([\\w-]{11})"
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsRange = NSRange(url.startIndex..., in: url)
        if let match = regex?.firstMatch(in: url, options: [], range: nsRange) {
            if let range = Range(match.range(at: 1), in: url) {
                return String(url[range])
            }
        }
        return nil
    }
}

extension PopularFeedDetailsVC: YTPlayerViewDelegate {
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        AlertManager.showBasicAlert(on: self, title: "Error Loading Video", message: "Please try again later.")
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct PopularFeedDetails_Preview: PreviewProvider {
    static var previews: some View {
        let movie = Movie(movieInfo: MovieDetails(title: "My Fault", year: 2023, ids: MovieIDs(tmdb: 1010581), tagline: nil, overview: "Noah must leave her city, boyfriend, and friends to move into William Leister's mansion, the flashy and wealthy husband of her mother Rafaela. As a proud and independent 17 year old, Noah resists living in a mansion surrounded by luxury. However, it is there where she meets Nick, her new stepbrother, and the clash of their strong personalities becomes evident from the very beginning.", runtime: 117, trailer: "https://youtube.com/watch?v=xY-qRGC6Yu0", rating: 7.03, genres: ["romance", "drama"], certification: "R"), posterURLString: "https://image.tmdb.org/t/p/original/lntyt4OVDbcxA1l7LtwITbrD3FI.jpg")
        PopularFeedDetailsVC(movie: movie).showPreview()
    }
}
#endif
