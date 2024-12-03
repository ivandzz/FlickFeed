//
//  UsersTableView.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 20.11.2024.
//

import UIKit

class UsersTableView: UIView {
    
    //MARK: - Variables
    private let firestoreManager = FirestoreManager()
    
    private var users: [User] = []
    private var currentQuery: String = ""
    private var searchWorkItem: DispatchWorkItem?
    
    private var isSearching = false {
        didSet {
            users.removeAll()
            firestoreManager.resetAllUsersPagination()
            firestoreManager.resetSearchUsersPagination()
        }
    }
    
    private var isLoading = false {
        didSet {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }
    
    //MARK: - UI Components
    private let searchBar = FFSearchBar(placeholder: "Search for Users")
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UserTableCell.self, forCellReuseIdentifier: UserTableCell.identifier)
        tableView.separatorColor = .white
        tableView.allowsSelection = true
        tableView.backgroundColor = .black
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let activityIndicator = FFActivityIndicator()
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        fetchAllUsers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .black
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setupSearchBar()
        setupTableView()
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
    
    //MARK: - Networking
    private func fetchAllUsers() {
        isLoading = true
        
        firestoreManager.fetchAllUsers { [weak self] users, error in
            guard let self else { return }
            
            if let error {
                self.showErrorAlert(message: error.localizedDescription)
                self.isLoading = false
                return
            }
            
            if let users {
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    self.users.append(contentsOf: users)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func searchUsers(with query: String, resetPagination: Bool) {
        isLoading = true
        
        firestoreManager.searchUsers(query.lowercased(), resetPagination: resetPagination) { [weak self] users, error in
            guard let self else { return }
            
            if let error {
                self.showErrorAlert(message: error.localizedDescription)
                self.isLoading = false
                return
            }
            
            if let users {
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    self.users.append(contentsOf: users)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Helper functions
    private func showErrorAlert(message: String) {
        guard let parentVC = getParentVC() else { return }
        AlertManager.showBasicAlert(on: parentVC, title: "Something went wrong", message: message)
    }
    
    private func setupEmptyState() {
        if users.isEmpty {
            let label = FFLabel(font: .systemFont(ofSize: 18, weight: .semibold), alignment: .center)
            label.setText("No results found.", prependedBySymbolNamed: "person.slash")
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

//MARK: - UITableViewDelegate
extension UsersTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setupEmptyState()
        
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableCell.identifier, for: indexPath) as! UserTableCell
        
        let user = users[indexPath.row]
        cell.configure(with: user)
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension UsersTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.item]
        
        guard let parentVC = getParentVC() else { return }
        let vc = ProfileVC(user: user)
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let position = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let frameHeight = scrollView.frame.size.height

            if position > contentHeight - frameHeight - 100, !isLoading {
                isSearching ? searchUsers(with: searchBar.text ?? "", resetPagination: false) : fetchAllUsers()
            }
        }
}

//MARK: - UISearchBarDelegate
extension UsersTableView: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchWorkItem?.cancel()
        
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard query != currentQuery else { return }
        currentQuery = query
        
        isSearching = true
        
        searchWorkItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            guard !query.isEmpty else {
                isSearching = false
                fetchAllUsers()
                tableView.reloadData()
                return
            }

            searchUsers(with: searchText, resetPagination: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: searchWorkItem!)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        firestoreManager.resetSearchUsersPagination()
        currentQuery = ""
        isSearching = false
        tableView.reloadData()
    }
}
