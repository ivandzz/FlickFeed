//
//  MovieTableCell.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 19.11.2024.
//

import UIKit

class MovieTableCell: UITableViewCell {
    
    // MARK: - Variables
    static let identifier = "MovieTableCell"
    
    //MARK: - UI Components
    let movieImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode   = .scaleAspectFit
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let titleLabel = FFLabel(font: .systemFont(ofSize: 15, weight: .bold), lines: 2)
    
    private let voteLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
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
    
    private let overviewLabel = FFLabel(font: .systemFont(ofSize: 12, weight: .medium))
    
    //MARK: Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        movieImageView.image = nil
        titleLabel.text      = nil
        voteLabel.text       = nil
        genresStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    //MARK: UI Setup
    private func setupUI() {
        self.backgroundColor = .black
        
        setupMovieImageView()
        setupMainLabels()
        setupGenresStack()
        setupOverviewLabel()
    }
    
    private func setupMovieImageView() {
        contentView.addSubview(movieImageView)
        
        NSLayoutConstraint.activate([
            movieImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            movieImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            movieImageView.widthAnchor.constraint(equalToConstant: 100),
            movieImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    private func setupMainLabels() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(voteLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: movieImageView.trailingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: voteLabel.leadingAnchor, constant: -10),
            
            voteLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            voteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            voteLabel.widthAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setupGenresStack() {
        contentView.addSubview(genresStack)
        
        NSLayoutConstraint.activate([
            genresStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            genresStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            genresStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    private func setupOverviewLabel() {
        contentView.addSubview(overviewLabel)
        
        NSLayoutConstraint.activate([
            overviewLabel.topAnchor.constraint(equalTo: genresStack.bottomAnchor, constant: 5),
            overviewLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            overviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            overviewLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    //MARK: - Configuration
    func configure(with movie: Movie) {
        titleLabel.text = movie.movieInfo.title
        overviewLabel.text = movie.movieInfo.overview
        
        voteLabel.setText("\(movie.movieInfo.rating.rounded(toPlaces: 1))",
                          prependedBySymbolNamed: "star.fill", imageTintColor: .yellow)
        
        if let url = URL(string: movie.posterURLString) {
            movieImageView.kf.indicatorType = .activity
            movieImageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
        } else {
            movieImageView.image = UIImage(named: "placeholderImage")
        }
        
        movie.movieInfo.genres.forEach { genre in
            let label = BackgroundLabel(text: genre.uppercased(), font: .systemFont(ofSize: 14), backgroundColor: .systemBlue)
            genresStack.addArrangedSubview(label)
        }
    }
}
