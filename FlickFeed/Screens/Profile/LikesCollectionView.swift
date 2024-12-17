//
//  LikesCollectionView.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 04.11.2024.
//

import UIKit

class LikesCollectionView: UIView {
    
    // MARK: - Variables
    private var movies: [Movie] = []
    private var filteredMovies: [Movie] = []
    private var isSearching = false
    private var isLoading = false {
        didSet {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - UI Components
    private let searchBar = FFSearchBar(placeholder: "Search For Liked Movies")
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(MovieCollectionCell.self, forCellWithReuseIdentifier: MovieCollectionCell.identifier)
        collectionView.backgroundColor      = .black
        collectionView.contentInset         = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let activityIndicator = FFActivityIndicator()
    
    // MARK: - Lifecycle
    init() {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .black
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
        
        setupSearchBar()
        setupCollectionView()
        setupActivityIndicator()
    }
    
    private func setupSearchBar() {
        self.addSubview(searchBar)
        
        searchBar.delegate = self
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func setupCollectionView() {
        self.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate   = self
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        self.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    // MARK: - Selectors
    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Networking
    public func fetchMovies(with likedIds: [Int]) {
        guard !isLoading else { return }
        isLoading = true
        
        NetworkManager.shared.getLikedMovies(with: likedIds) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let movies):
                    self.movies = movies
                    self.filteredMovies = movies
                    self.collectionView.reloadData()
                case .failure(let error):
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helper functions
    private func showErrorAlert(message: String) {
        guard let parentVC = getParentVC() else { return }
        AlertManager.showBasicAlert(on: parentVC, title: "Something Went Wrong", message: message)
    }
}

// MARK: - UICollectionViewDataSource
extension LikesCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dataSource = isSearching ? filteredMovies : movies
        
        if dataSource.isEmpty {
            let label = FFLabel(font: .systemFont(ofSize: 18, weight: .semibold), alignment: .center)
            label.setText(isSearching ? "No results found." : "No movies liked yet.", prependedBySymbolNamed: "play.slash")
            collectionView.backgroundView = label
        } else {
            collectionView.backgroundView = nil
        }
        
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionCell.identifier, for: indexPath) as! MovieCollectionCell
        let movie = isSearching ? filteredMovies[indexPath.row] : movies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension LikesCollectionView: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movie = isSearching ? filteredMovies[indexPath.item] : movies[indexPath.item]
        
        guard let parentVC = getParentVC() else { return }
        let vc = MovieDetailsVC(movie: movie)
        vc.modalPresentationStyle = .pageSheet
        parentVC.present(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? MovieCollectionCell else { return }
        cell.imageView.kf.cancelDownloadTask()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension LikesCollectionView: UICollectionViewDelegateFlowLayout {
    
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

extension LikesCollectionView: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            isSearching = false
            filteredMovies = movies
            collectionView.reloadData()
            return
        }
        
        isSearching = true
        filteredMovies = movies.filter { $0.movieInfo.title.lowercased().contains(searchText.lowercased()) }
        collectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        filteredMovies = movies
        collectionView.reloadData()
    }
}
