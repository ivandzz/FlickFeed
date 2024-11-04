//
//  FeedVC.swift
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
    private var movies: [Movie] = []
    private var isLoading = false
    private var page = 1
    private var movieSet = Set<Int>()
    
    // MARK: - UI Components
    private var collectionView: UICollectionView?
    
    private let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cache = ImageCache.default
        // Limit memory cache size to 50 MB.
        cache.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
        
        setupUI()
        getMovies(page: page)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchLastStoppedValue()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveLastStoppedValue()
        ImageCache.default.clearMemoryCache()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let height = view.frame.size.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom
        layout.itemSize = CGSize(width: view.frame.size.width, height: height)
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.isPagingEnabled = true
        collectionView?.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.contentInsetAdjustmentBehavior = .never
        collectionView?.backgroundColor = .black
        
        view.addSubview(collectionView!)
        view.addSubview(activityIndicator)
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Networking
    private func getMovies(page: Int) {
        guard !isLoading else { return }
        isLoading = true
        activityIndicator.startAnimating()
        
        NetworkManager.shared.getMovies(page: page) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                self.activityIndicator.stopAnimating()
                switch result {
                case .success(let moviesResponse):
                    let newMovies = moviesResponse.filter { newMovie in
                        !self.movies.contains(where: { $0.movieInfo.ids.tmdb == newMovie.movieInfo.ids.tmdb })
                    }
                    
                    if !newMovies.isEmpty {
                        self.movies.append(contentsOf: newMovies)
                        self.page += 1
                        self.collectionView?.reloadData()
                    }
                    
                case .failure(let error):
                    AlertManager.showBasicAlert(on: self, title: "Something went wrong", message: error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Firebase Methods
    private func saveLastStoppedValue() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        let lastStoppedIndex = collectionView?.contentOffset.y ?? 0
        
        db.collection("users").document(userId).setData([
            "lastStoppedValue": lastStoppedIndex,
            "lastStoppedPage": page
        ], merge: true) { error in
            if let error = error {
                AlertManager.showBasicAlert(on: self, title: "Error Saving Data", message: error.localizedDescription)
            }
        }
    }
    
    private func fetchLastStoppedValue() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showBasicAlert(on: self, title: "Error Fetching Data", message: error.localizedDescription)
            }
            
            if let document = document, document.exists {
                let lastStoppedValue = document.get("lastStoppedValue") as? CGFloat ?? 0
                let lastStoppedPage = document.get("lastStoppedPage") as? Int ?? 1
                
                self.collectionView?.setContentOffset(CGPoint(x: 0, y: lastStoppedValue), animated: false)
                self.page = lastStoppedPage
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
        let movie = movies[indexPath.row]
        let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
        cell.configure(with: movie, tabBarHeight: tabBarHeight)
        
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
            getMovies(page: page)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let movieCell = cell as? MovieCell else { return }
        movieCell.imageView.kf.cancelDownloadTask()
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
