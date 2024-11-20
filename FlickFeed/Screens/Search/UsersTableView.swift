//
//  UsersTableView.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 20.11.2024.
//

import UIKit

class UsersTableView: UIView {
    
    //MARK: - Variables
    private var users: [User] = []
    private var filteredUsers: [User] = []
    private var isSearching = false
    
    private var isLoading = false {
        didSet {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }
    
    //MARK: - UI Components
    private let searchBar = FFSearchBar(placeholder: "Search for Users")
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
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
        
        AuthManager.shared.fetchAllUsers { [weak self] users, error in
            guard let self = self else { return }
            
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
                return
            }
            
            if let users = users {
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    self.users = users
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
}

//MARK: - UITableViewDelegate
extension UsersTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let dataSource = isSearching ? filteredUsers : users
        setupEmptyState(isEmpty: dataSource.isEmpty)
        
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableCell.identifier, for: indexPath) as! UserTableCell
        
        let user = isSearching ? filteredUsers[indexPath.row] : users[indexPath.row]
        cell.configure(with: user)
        
        return cell
    }
    
    //MARK: - Helper functions
    private func setupEmptyState(isEmpty: Bool) {
        if isEmpty {
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
extension UsersTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = isSearching ? filteredUsers[indexPath.item] : users[indexPath.item]
        
        guard let parentVC = getParentVC() else { return }
        let vc = ProfileVC(user: user)
        parentVC.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - UISearchBarDelegate
extension UsersTableView: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            isSearching = false
            filteredUsers = users
            tableView.reloadData()
            return
        }
        
        isSearching = true
        filteredUsers = users.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        filteredUsers = users
        tableView.reloadData()
    }
}
