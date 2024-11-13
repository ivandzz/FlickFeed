//
//  MovieCell.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 23/10/24.
//

import UIKit
import Kingfisher
import FirebaseFirestore
import FirebaseAuth

class MovieCell: UICollectionViewCell {
    
    // MARK: - Variables
    static let identifier = "MovieCell"
    
    private var movie: Movie?
    
    private var placeholderHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI Components
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode   = .scaleToFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel    = FFLabel(font: .systemFont(ofSize: 18, weight: .bold), lines: 2)
    
    private let voteLabel: UILabel = {
        let label = UILabel()
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
    
    private let overviewLabel = FFLabel(font: .systemFont(ofSize: 14, weight: .medium))

    private let placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [overviewLabel, placeholderView])
        stackView.axis         = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment    = .top
        stackView.spacing      = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let likeButton = LikeButton(size: 30)
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        imageView.image    = nil
        titleLabel.text    = nil
        overviewLabel.text = nil
        voteLabel.text     = nil
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        contentView.backgroundColor = .black
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(voteLabel)
        contentView.addSubview(stackView)
        contentView.addSubview(likeButton)
        contentView.addSubview(genresStack)
        
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        contentView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.75),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: voteLabel.leadingAnchor, constant: -10),
            
            voteLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            voteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            voteLabel.widthAnchor.constraint(equalToConstant: 55),
            
            genresStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            genresStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genresStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            genresStack.bottomAnchor.constraint(equalTo: stackView.topAnchor, constant: -5),
            
            stackView.topAnchor.constraint(equalTo: genresStack.bottomAnchor, constant: 5),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            likeButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    // MARK: - Selectors
    @objc private func didTapCell(_ sender: UITapGestureRecognizer) {
        
        let location = sender.location(in: contentView)
        
        if likeButton.frame.contains(location) { return }
        
        guard let parentVC = getParentVC() else { return }
        let vc = MovieDetailsVC(movie: movie!)
        vc.modalPresentationStyle = .pageSheet
        parentVC.present(vc, animated: true)
    }
    
    @objc func likeButtonTapped() {
        UIView.animate(withDuration: 0.2) {
            self.likeButton.transform = self.likeButton.isSelected ? .identity : CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
        
        likeButton.isSelected.toggle()
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let movieId = movie?.movieInfo.ids.tmdb else { return }
        
        let db = Firestore.firestore()
        let likesRef = db.collection("users").document(userId)
        
        likesRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let error = error {
                AlertManager.showBasicAlert(on: self.getParentVC()!, title: "Error Retrieving Data", message: error.localizedDescription)
                return
            }
            
            var likedMovies = document?.data()?["likedMovies"] as? [Int] ?? []
            
            if let index = likedMovies.firstIndex(of: movieId) {
                likedMovies.remove(at: index)
            } else {
                likedMovies.append(movieId)
            }
            
            likesRef.setData(["likedMovies": likedMovies], merge: true) { error in
                if let error = error {
                    AlertManager.showBasicAlert(on: self.getParentVC()!, title: "Error Saving Data", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Configuration
    func configure(with movie: Movie, tabBarHeight: CGFloat) {
        self.movie = movie
        
        titleLabel.text = movie.movieInfo.title
        overviewLabel.text = movie.movieInfo.overview
        voteLabel.setText("\(movie.movieInfo.rating.rounded(toPlaces: 1))",
                          prependedBySymbolNameed: "star.fill",
                          imageTintColor: .yellow,
                          font: .systemFont(ofSize: 18))
        
        if let url = URL(string: movie.posterURLString) {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
        } else {
            imageView.image = UIImage(named: "placeholderImage")
        }
        
        isLiked()
        
        genresStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        movie.movieInfo.genres.forEach { genre in
            let label = BackgroundLabel(text: genre, font: .systemFont(ofSize: 15), alignment: .center, backgroundColor: .systemBlue)
            label.padding = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
            self.genresStack.addArrangedSubview(label)
        }
        
        if let constraint = placeholderHeightConstraint {
            constraint.constant = tabBarHeight
        } else {
            placeholderHeightConstraint = placeholderView.heightAnchor.constraint(equalToConstant: tabBarHeight)
            placeholderHeightConstraint?.isActive = true
        }
    }
    
    private func isLiked() {
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let likesRef = db.collection("users").document(userId)
        
        likesRef.getDocument { [weak self] (document, error) in
            guard let self = self else { return }
            if let error = error {
                print("Error retrieving liked movies: \(error)")
                return
            }
            
            let likedMovies = document?.data()?["likedMovies"] as? [Int] ?? []
            self.likeButton.isSelected = likedMovies.contains((movie?.movieInfo.ids.tmdb)!)
        }
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct PopularFeedVC1_Preview: PreviewProvider {
    static var previews: some View {
        PopularFeedVC().showPreview()
    }
}
#endif
