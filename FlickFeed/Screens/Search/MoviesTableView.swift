//
//  MoviesTableView.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 18.11.2024.
//

import UIKit

class MoviesTableView: UIView {
    
    // MARK: - Variables
    private var movies: [Movie] = []
    private var page = 1
    private var currentQuery: String = ""
    private var searchWorkItem: DispatchWorkItem?
    
    private var isLoading = false {
        didSet {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - UI Components
    private let searchBar = FFSearchBar(placeholder: "Search for Movies")
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.backgroundColor = .black
        tableView.register(MovieTableCell.self, forCellReuseIdentifier: MovieTableCell.identifier)
        tableView.separatorColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let activityIndicator = FFActivityIndicator()
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .black
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setupSearchBar()
        setupTableView()
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
    
    private func setupTableView() {
        self.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate   = self
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
            tableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        self.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    // MARK: - Search Logic
    private func searchForMovies(with query: String, page: Int) {
        guard !isLoading else { return }
        isLoading = true
        
        if page == 1 {
            movies.removeAll()
            tableView.reloadData()
        }
        
        NetworkManager.shared.searchForMovies(with: query, page: page) { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let moviesResponse):
                    let newMovies = moviesResponse.filter { newMovie in
                        !self.movies.contains(where: { $0.movieInfo.ids.tmdb == newMovie.movieInfo.ids.tmdb })
                    }
                    guard !newMovies.isEmpty else { return }
                    
                    let startIndex = self.movies.count
                    let indexPaths = newMovies.indices.map { IndexPath(row: startIndex + $0, section: 0) }
                    self.movies.append(contentsOf: newMovies)
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                    
                case .failure(let error):
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Helper functions
    private func showErrorAlert(message: String) {
        guard let parentVC = getParentVC() else { return }
        AlertManager.showBasicAlert(on: parentVC, title: "Something went wrong", message: message)
    }
}

// MARK: - UITableViewDataSource
extension MoviesTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setupEmptyState(isEmpty: movies.isEmpty)
        
        return movies.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableCell.identifier, for: indexPath) as! MovieTableCell
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    //MARK: - Helper functions
    private func setupEmptyState(isEmpty: Bool) {
        if isEmpty {
            let label = FFLabel(font: .systemFont(ofSize: 18, weight: .semibold), alignment: .center)
            label.setText(currentQuery.isEmpty ? "Enter your query." : "No results found.", prependedBySymbolNamed: "play.slash")
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let backgroundView = UIView()
            backgroundView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
            ])
            
            tableView.backgroundView = backgroundView
        } else {
            tableView.backgroundView = nil
        }
    }
}

// MARK: - UITableViewDelegate
extension MoviesTableView: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height * 2, !isLoading, !currentQuery.isEmpty {
            page += 1
            searchForMovies(with: currentQuery, page: page)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? MovieTableCell else { return }
        cell.movieImageView.kf.cancelDownloadTask()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let movie = movies[indexPath.row]
        let vc = MovieDetailsVC(movie: movie)
        self.getParentVC()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

// MARK: - UISearchBarDelegate
extension MoviesTableView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard query != currentQuery else { return }
        currentQuery = query
        
        searchWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard !query.isEmpty else {
                self.movies.removeAll()
                self.tableView.reloadData()
                return
            }
            self.page = 1
            self.movies.removeAll()
            self.tableView.reloadData()
            self.searchForMovies(with: query, page: self.page)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: searchWorkItem!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        currentQuery = ""
        page = 1
        movies.removeAll()
        tableView.reloadData()
    }
}
