//
//  PopularFeedVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 23/10/24.
//

import UIKit
import Kingfisher
import FirebaseFirestore
import FirebaseAuth

class PopularFeedVC: UIViewController {
    
    // MARK: - Variables
    private let firestoreManager = FirestoreManager()
    
    private var movies: [Movie] = []
    private var page = 1
    
    private var isLoading = false {
        didSet {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - UI Components
    private var collectionView: UICollectionView?
    
    private let activityIndicator = FFActivityIndicator()
    
    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchLastStoppedValue()
        fetchMovies(page: page)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Limit memory cache size to 50 MB.
        ImageCache.default.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
        
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView?.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveLastStoppedValue()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupCollectionView()
        setupActivityIndicator()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let height = view.frame.size.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        layout.itemSize = CGSize(width: view.frame.size.width, height: height)
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        guard let collectionView else { return }
        collectionView.isPagingEnabled = true
        collectionView.register(FeedMovieCollectionCell.self, forCellWithReuseIdentifier: FeedMovieCollectionCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .black
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Networking
    private func fetchMovies(page: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        NetworkManager.shared.getMovies(page: page) { [weak self] result in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let moviesResponse):
                    let newMovies = moviesResponse.filter { newMovie in
                        !self.movies.contains(where: { $0.movieInfo.ids.tmdb == newMovie.movieInfo.ids.tmdb })
                    }
                    
                    if !newMovies.isEmpty {
                        self.movies.append(contentsOf: newMovies)
                        self.collectionView?.reloadData()
                    }
                    
                case .failure(let error):
                    AlertManager.showBasicAlert(on: self, title: "Something went wrong", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func saveLastStoppedValue() {
        firestoreManager.saveLastStoppedValue(lastValue: collectionView?.contentOffset.y ?? 0, page: page) { [weak self] error in
            guard let self else { return }
            if let error {
                AlertManager.showBasicAlert(on: self, title: "Error Saving Data", message: error.localizedDescription)
            }
        }
    }
    
    private func fetchLastStoppedValue() {
        firestoreManager.fetchLastStoppedValue { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let (lastValue, lastPage)):
                self.collectionView?.setContentOffset(CGPoint(x: 0, y: lastValue), animated: false)
                self.page = lastPage
            case .failure(let error):
                AlertManager.showBasicAlert(on: self, title: "Error Fetching Data", message: error.localizedDescription)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension PopularFeedVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeedMovieCollectionCell.identifier, for: indexPath) as! FeedMovieCollectionCell
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PopularFeedVC: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 2 && !isLoading {
            page += 1
            fetchMovies(page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? FeedMovieCollectionCell else { return }
        cell.imageView.kf.cancelDownloadTask()
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct PopularFeedVC_Preview: PreviewProvider {
    static var previews: some View {
        PopularFeedVC().showPreview()
    }
}
#endif
