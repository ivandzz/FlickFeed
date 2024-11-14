//
//  PopularFeedDetailsVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 01.11.2024.
//

import UIKit
import YouTubeiOSPlayerHelper

class MovieDetailsVC: UIViewController {
    
    // MARK: - Variables
    private let movie: Movie
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let titleLabel = FFLabel(font: .systemFont(ofSize: 18, weight: .bold))
    
    private let voteLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var genresStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis         = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment    = .leading
        stackView.spacing      = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let overviewLabel    = FFLabel(font: .systemFont(ofSize: 14, weight: .medium))
    
    private let likeButton       = LikeButton(size: 30)
    
    private let playerView: YTPlayerView = {
        let playerView = YTPlayerView()
        playerView.translatesAutoresizingMaskIntoConstraints = false
        return playerView
    }()
    
    private let placeholderView = PlaceholderView()
    
    private lazy var infoStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis         = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment    = .leading
        stackView.spacing      = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let yearLabel    = BackgroundLabel(font: .systemFont(ofSize: 14, weight: .semibold), backgroundColor: .systemBlue)

    private let runtimeLabel = BackgroundLabel(font: .systemFont(ofSize: 14, weight: .semibold), backgroundColor: .systemBlue)

    private let ratingLabel  = BackgroundLabel(font: .systemFont(ofSize: 14, weight: .semibold), backgroundColor: .systemBlue)

    private let taglineLabel = FFLabel(font: .systemFont(ofSize: 16, weight: .semibold))
    
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode   = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        setupScrollView()
        setupMainLabels()
        setupLikeButton()
        setupPlayerView()
        setupInfoLabels()
        setupImageView()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupMainLabels() {
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(voteLabel)
        scrollView.addSubview(genresStack)
        scrollView.addSubview(overviewLabel)
        
        titleLabel.text    = movie.movieInfo.title
        overviewLabel.text = movie.movieInfo.overview
        
        voteLabel.setText("\(movie.movieInfo.rating.rounded(toPlaces: 1))", prependedBySymbolNamed: "star.fill", imageTintColor: .yellow, font: .systemFont(ofSize: 18))
        
        configureGenresLabels()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: voteLabel.leadingAnchor, constant: -10),
            
            voteLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            voteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            voteLabel.widthAnchor.constraint(equalToConstant: 55),
            
            genresStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            genresStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            genresStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            genresStack.bottomAnchor.constraint(equalTo: overviewLabel.topAnchor, constant: -5),
            
            overviewLabel.topAnchor.constraint(equalTo: genresStack.bottomAnchor, constant: 5),
            overviewLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            overviewLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupLikeButton() {
        scrollView.addSubview(likeButton)
        
        checkIfLiked()
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            likeButton.topAnchor.constraint(equalTo: overviewLabel.bottomAnchor, constant: 10),
            likeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupPlayerView() {
        scrollView.addSubview(playerView)
        playerView.addSubview(placeholderView)
        
        playerView.delegate = self
        
        if let trailer = movie.movieInfo.trailer,
           let videoID = extractVideoID(from: trailer) {
            playerView.load(withVideoId: videoID)
            placeholderView.isHidden = false
        } else {
            placeholderView.isHidden = false
        }
        
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: likeButton.bottomAnchor, constant: 10),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.heightAnchor.constraint(equalToConstant: 230),
            
            placeholderView.topAnchor.constraint(equalTo: playerView.topAnchor),
            placeholderView.leadingAnchor.constraint(equalTo: playerView.leadingAnchor),
            placeholderView.trailingAnchor.constraint(equalTo: playerView.trailingAnchor),
            placeholderView.bottomAnchor.constraint(equalTo: playerView.bottomAnchor)
        ])
    }
    
    private func setupInfoLabels() {
        scrollView.addSubview(infoStack)
        scrollView.addSubview(taglineLabel)
        
        if let year = movie.movieInfo.year {
            yearLabel.setText("\(year)", prependedBySymbolNamed: "calendar", imageTintColor: .white)
            infoStack.addArrangedSubview(yearLabel)
        }
        
        if let runtime = movie.movieInfo.runtime {
            runtimeLabel.setText("\(runtime) min", prependedBySymbolNamed: "clock")
            infoStack.addArrangedSubview(runtimeLabel)
        }
        
        if let rating = movie.movieInfo.certification {
            ratingLabel.setText(rating, prependedBySymbolNamed: "exclamationmark.circle")
            infoStack.addArrangedSubview(ratingLabel)
        }
        
        taglineLabel.text = movie.movieInfo.tagline ?? movie.movieInfo.title
        
        NSLayoutConstraint.activate([
            infoStack.topAnchor.constraint(equalTo: playerView.bottomAnchor, constant: 10),
            infoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            taglineLabel.topAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: 10),
            taglineLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupImageView() {
        scrollView.addSubview(imageView)
        
        if let url = URL(string: movie.backdropURLString) {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
        } else {
            imageView.image = UIImage(named: "placeholderImage")
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: taglineLabel.bottomAnchor, constant: 5),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 230),
            imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10),
        ])
    }
    
    //MARK: - Selectors
    @objc private func likeButtonTapped() {
        UIView.animate(withDuration: 0.2, animations: {
            self.likeButton.transform = self.likeButton.isSelected ? .identity : CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.likeButton.transform = .identity
            }
        }
        
        likeButton.isSelected.toggle()
        
        LikesManager.shared.updateLike(for: movie.movieInfo.ids.tmdb) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                AlertManager.showBasicAlert(on: self, title: "Something went wrong", message: error.localizedDescription)
                self.likeButton.isSelected.toggle()
            }
        }
    }
    
    //MARK: - Configuration
    private func configureGenresLabels() {
        movie.movieInfo.genres.forEach { genre in
            let label = BackgroundLabel(text: genre.uppercased(), font: .systemFont(ofSize: 14, weight: .semibold), alignment: .center, backgroundColor: .systemBlue)
            label.padding = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
            self.genresStack.addArrangedSubview(label)
        }
    }

    private func checkIfLiked() {
        LikesManager.shared.isLiked(movieId: movie.movieInfo.ids.tmdb) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let isLiked):
                self.likeButton.isSelected = isLiked
            case .failure(let error):
                AlertManager.showBasicAlert(on: self, title: "Something went wrong", message: error.localizedDescription)
            }
        }
    }
    
    //MARK: - Helper Functions
    private func extractVideoID(from url: String) -> String? {
        guard let urlComponents = URLComponents(string: url),
              let queryItems = urlComponents.queryItems else { return nil }
        return queryItems.first(where: { $0.name == "v" })?.value
    }
}

//MARK: - YTPlayerViewDelegate
extension MovieDetailsVC: YTPlayerViewDelegate {
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        AlertManager.showBasicAlert(on: self, title: "Error Loading Video", message: "Please try again later.")
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct MovieDetails_Preview: PreviewProvider {
    static var previews: some View {
        MovieDetailsVC(movie: MovieMockData.sampleMovie).showPreview()
    }
}
#endif
