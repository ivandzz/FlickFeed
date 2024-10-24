//
//  FeedVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 23/10/24.
//

import UIKit

class PopularFeedVC: UIViewController {
    
    private var collectionView: UICollectionView?
    
    private var movies: [Movie] = []
    private var isLoading = false
    private var page = 1
    private var totalPages = 1
    private var movieSet = Set<Int>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 0
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.isPagingEnabled = true
        collectionView?.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.identifier)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(collectionView!)
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
                    let newMovies = moviesResponse.results.filter { newMovie in
                        !self.movies.contains(where: { $0.id == newMovie.id })
                    }
                    
                    if !newMovies.isEmpty {
                        self.movies.append(contentsOf: newMovies)
                        self.totalPages = moviesResponse.total_pages
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
}

// MARK: - UICollectionViewDataSource
extension PopularFeedVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movie = movies[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCell.identifier, for: indexPath) as! MovieCell
        cell.configure(with: movie)
        
        if indexPath.item == movies.count - 1 && page <= totalPages {
            getMovies(page: page)
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PopularFeedVC: UICollectionViewDelegate {
    
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
