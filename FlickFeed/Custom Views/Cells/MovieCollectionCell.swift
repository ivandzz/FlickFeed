//
//  MovieCollectionCell.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 04.11.2024.
//

import UIKit

class MovieCollectionCell: UICollectionViewCell {
    
    //MARK: - Variables
    static let identifier = "MovieCollectionCell"
    
    //MARK: - UI Components
    let imageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let titleLabel = FFLabel(font: .monospacedSystemFont(ofSize: 13, weight: .semibold), alignment: .center, lines: 2)
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        titleLabel.text = nil
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .black
        
        setupImageView()
        setupTitleLabel()
    }
    
    private func setupImageView() {
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.85)
        ])
    }
    
    private func setupTitleLabel() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2)
        ])
    }
    
    //MARK: - Configure
    func configure(with movie: Movie) {
        titleLabel.text = movie.movieInfo.title
        
        if let url = URL(string: movie.posterURLString) {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
        } else {
            imageView.image = UIImage(named: "placeholderImage")
        }
    }
}
