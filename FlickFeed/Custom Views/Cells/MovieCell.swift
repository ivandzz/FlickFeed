//
//  MovieCell.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 23/10/24.
//

import UIKit
import Kingfisher

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
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
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
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setupUI()
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        
        imageView.image    = nil
        titleLabel.text    = nil
        overviewLabel.text = nil
        voteLabel.text     = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        contentView.backgroundColor = .black
        contentView.clipsToBounds   = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(voteLabel)
        contentView.addSubview(stackView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapContentView))
        contentView.addGestureRecognizer(tapGesture)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor, multiplier: 0.75),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: voteLabel.leadingAnchor, constant: -10),
            
            voteLabel.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            voteLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            voteLabel.widthAnchor.constraint(equalToConstant: 65),
            
            stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Selectors
    @objc private func didTapContentView(_ sender: UITapGestureRecognizer) {

        let location = sender.location(in: contentView)

        if imageView.frame.contains(location) { return }
 
        guard let parentVC = getParentVC() else { return }
        let vc = PopularFeedDetailsVC(movie: movie!)
        vc.modalPresentationStyle = .pageSheet
        parentVC.present(vc, animated: true)
    }
    
    // MARK: - Configuration
    func configure(with movie: Movie, tabBarHeight: CGFloat) {
        
        self.movie = movie
        
        titleLabel.text    = movie.movieInfo.title
        overviewLabel.text = movie.movieInfo.overview
        voteLabel.text     = "\(movie.movieInfo.rating.rounded(toPlaces: 1))/10"
        
        if let url = URL(string: movie.posterURLString) {
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "placeholderImage"))
        }
        
        if let constraint = placeholderHeightConstraint {
            constraint.constant = tabBarHeight
        } else {
            placeholderHeightConstraint           = placeholderView.heightAnchor.constraint(equalToConstant: tabBarHeight)
            placeholderHeightConstraint?.isActive = true
        }
    }
    
    //MARK: - Helper Functions
    private func getParentVC() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
