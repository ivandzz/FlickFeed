//
//  FeedVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 23/10/24.
//

import UIKit
import Kingfisher

class PopularFeedVC: UIViewController {
    
    private var collectionView: UICollectionView?
    
    private var movies: [Movie] = []
    private var isLoading = false
    private var page = 1
    private var movieSet = Set<Int>()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let cache = ImageCache.default
        // Limit memory cache size to 50 MB.
        cache.memoryStorage.config.totalCostLimit = 50 * 1024 * 1024
        
        configureUI()
        getMovies(page: page)
    }
    
    
    private func configureUI() {
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
        
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    
    private func getMovies(page: Int) {
        
        guard !isLoading else { return }
        isLoading = true
        
        NetworkManager.shared.getMovies(page: page) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let moviesResponse):
                    let newMovies = moviesResponse.filter { newMovie in
                        !self.movies.contains(where: { $0.movie.movie.ids.tmdb == newMovie.movie.movie.ids.tmdb })
                    }
                    
                    if !newMovies.isEmpty {
                        self.movies.append(contentsOf: newMovies)
                        self.page += 1
                        self.collectionView?.reloadData()
                    }
                    
                case .failure(let error):
                    print("Error fetching movies: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        ImageCache.default.clearMemoryCache()
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
        
        if offsetY > contentHeight - height * 2 {
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
struct FeedVC_Preview: PreviewProvider {
    static var previews: some View {
        PopularFeedVC().showPreview()
    }
}
#endif
