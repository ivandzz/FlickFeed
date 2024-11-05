//
//  LikesView.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 04.11.2024.
//

import UIKit

class LikesView: UIView {
    
    // MARK: - Variables
    private var movies: [Movie] = []
    
    // MARK: - UI Components
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(LikeCell.self, forCellWithReuseIdentifier: LikeCell.identifier)
        collectionView.backgroundColor      = .black
        collectionView.contentInset         = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Lifecycle
    init() {
        super.init(frame: .zero)
        collectionView.dataSource = self
        collectionView.delegate   = self
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .black
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func getMovies(with likedIds: [Int]) {
        NetworkManager.shared.getLikedMovies(with: likedIds) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                
                switch result {
                case .success(let movies):
                    self.movies = movies
                    self.collectionView.reloadData()
                case .failure(let error):
                    AlertManager.showBasicAlert(on: self.getParentVC()!, title: "Something went wrong", message: error.localizedDescription)
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension LikesView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LikeCell.identifier, for: indexPath) as! LikeCell
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension LikesView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = movies[indexPath.item]
        
        guard let parentVC = getParentVC() else { return }
        let vc = MovieDetailsVC(movie: movie)
        vc.modalPresentationStyle = .pageSheet
        parentVC.present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let movieCell = cell as? LikeCell else { return }
        movieCell.imageView.kf.cancelDownloadTask()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LikesView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (self.collectionView.bounds.width/3)-1.34
        return CGSize(width: size, height: size * 1.8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
}
