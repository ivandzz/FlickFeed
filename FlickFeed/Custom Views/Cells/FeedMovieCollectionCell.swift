//
//  FeedMovieCollectionCell.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 23/10/24.
//

import UIKit
import Kingfisher

class FeedMovieCollectionCell: UICollectionViewCell {
    
    // MARK: - Variables
    static let identifier = "FeedMovieCollectionCell"
    
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
    
    private let likeButton    = LikeButton(size: 30)
    private let titleLabel    = FFLabel(font: .systemFont(ofSize: 16, weight: .bold), lines: 2)
    private let overviewLabel = FFLabel(font: .systemFont(ofSize: 14, weight: .medium))
    
    private let voteLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
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
    
    //Placeholder to make sure the cell's height is correct with the tab bar
    private let placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var placeholderStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [overviewLabel, placeholderView])
        stackView.axis         = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment    = .top
        stackView.spacing      = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
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
        genresStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = .black
        setupImageView()
        setupLikeButton()
        setupLabels()
    }
    
    private func setupImageView() {
        contentView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.75)
        ])
    }
    
    private func setupLikeButton() {
        contentView.addSubview(likeButton)
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCell))
        contentView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            likeButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    private func setupLabels() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(voteLabel)
        contentView.addSubview(genresStack)
        contentView.addSubview(placeholderStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: voteLabel.leadingAnchor, constant: -10),
            
            voteLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            voteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            voteLabel.widthAnchor.constraint(equalToConstant: 60),
            
            genresStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            genresStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            genresStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            genresStack.bottomAnchor.constraint(equalTo: placeholderStack.topAnchor, constant: -5),
            
            placeholderStack.topAnchor.constraint(equalTo: genresStack.bottomAnchor, constant: 5),
            placeholderStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            placeholderStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            placeholderStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Selectors
    @objc private func didTapCell(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: contentView)
        if likeButton.frame.contains(location) { return }
        
        guard let parentVC = getParentVC(), let movie = movie else { return }
        let vc = MovieDetailsVC(movie: movie)
        vc.modalPresentationStyle = .pageSheet
        parentVC.present(vc, animated: true)
    }
    
    @objc private func likeButtonTapped() {
        UIView.animate(withDuration: 0.2, animations: {
            self.likeButton.transform = self.likeButton.isSelected ? .identity : CGAffineTransform(scaleX: 1.2, y: 1.2)
        }) { [weak self] _ in
            guard let self else { return }
            UIView.animate(withDuration: 0.2) {
                self.likeButton.transform = .identity
            }
        }
        
        likeButton.isSelected.toggle()
        
        guard let movieId = movie?.movieInfo.ids.tmdb else { return }
        LikesManager.shared.updateLike(for: movieId) { [weak self] error in
            guard let self else { return }
            if let error {
                self.showErrorAlert(message: error.localizedDescription)
                self.likeButton.isSelected.toggle()
            }
        }
    }
    
    // MARK: - Configuration
    func configure(with movie: Movie) {
        self.movie = movie
        
        configureImageView()
        configureLikeButton()
        configureLabels()
        configurePlaceholderHeight()
    }
    
    private func configureImageView() {
        if let url = URL(string: movie?.posterURLString ?? "") {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
        } else {
            imageView.image = UIImage(named: "placeholderImage")
        }
    }
    
    private func configureLikeButton() {
        guard let movieId = movie?.movieInfo.ids.tmdb else { return }
        LikesManager.shared.isLiked(movieId: movieId) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let isLiked):
                self.likeButton.isSelected = isLiked
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
    
    private func configureLabels() {
        titleLabel.text = movie?.movieInfo.title
        overviewLabel.text = movie?.movieInfo.overview
        voteLabel.setText("\(movie?.movieInfo.rating.rounded(toPlaces: 1) ?? 0.0)", prependedBySymbolNamed: "star.fill", imageTintColor: .yellow)
        configureGenres()
    }
    
    private func configureGenres() {
        movie?.movieInfo.genres.forEach { genre in
            let label = BackgroundLabel(text: genre.uppercased(), font: .systemFont(ofSize: 14), backgroundColor: .systemBlue)
            genresStack.addArrangedSubview(label)
        }
    }
    
    private func configurePlaceholderHeight() {
        let tabBarHeight = getParentVC()?.tabBarController?.tabBar.frame.height
        placeholderView.heightAnchor.constraint(equalToConstant: tabBarHeight ?? 0).isActive = true
    }
    
    //MARK: - Helper functions
    private func showErrorAlert(message: String) {
        guard let parentVC = getParentVC() else { return }
        AlertManager.showBasicAlert(on: parentVC, title: "Something went wrong", message: message)
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
