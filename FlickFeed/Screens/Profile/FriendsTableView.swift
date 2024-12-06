//
//  FriendsTableView.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 06.12.2024.
//

import UIKit

class FriendsTableView: UIView {
    
    //MARK: - Variables
    private var friends: [User] = []
    private var filteredFriends: [User] = []
    private var isSearching = false
    
    private var isLoading = false {
        didSet {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }
    
    //MARK: - UI Components
    private let searchBar = FFSearchBar(placeholder: "Search Friends")
    
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
    init() {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .black
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
        
        setupSearchBar()
        setupTableView()
    }
    
    private func setupSearchBar() {
        self.addSubview(searchBar)
        
        searchBar.delegate = self
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
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
    
    // MARK: - Selectors
    @objc private func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    //MARK: - Networking
    public func fetchFriends(with friendsUIDs: [String]) {
        
        if friendsUIDs.isEmpty { return }
        
        isLoading = true
        let dispatchGroup = DispatchGroup()

        for uid in friendsUIDs {
            dispatchGroup.enter()
            
            AuthManager.shared.fetchUser(with: uid) { [weak self] friend, error in
                guard let self else {
                    dispatchGroup.leave()
                    return
                }
                
                DispatchQueue.main.async {
                    if let error {
                        self.showErrorAlert(message: error.localizedDescription)
                    } else if let friend {
                        self.friends.append(friend)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.isLoading = false
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Helper functions
    private func showErrorAlert(message: String) {
        guard let parentVC = getParentVC() else { return }
        AlertManager.showBasicAlert(on: parentVC, title: "Something went wrong", message: message)
    }
    
    private func setupEmptyState() {
        if friends.isEmpty || (isSearching && filteredFriends.isEmpty) {
            let label = FFLabel(font: .systemFont(ofSize: 18, weight: .semibold), alignment: .center)
            label.setText(isSearching ? "No Matching Friends Found" : "No Friends to Show", prependedBySymbolNamed: "person.slash")
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

//MARK: - UITableViewDataSource
extension FriendsTableView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        setupEmptyState()
        
        return isSearching ? filteredFriends.count : friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableCell.identifier, for: indexPath) as! UserTableCell
        
        let friend = isSearching ? filteredFriends[indexPath.row] : friends[indexPath.row]
        cell.configure(with: friend)
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension FriendsTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = isSearching ? filteredFriends[indexPath.row] : friends[indexPath.row]
        
        let profileVC = ProfileVC(user: friend)
        guard let parentVC = getParentVC() else { return }
        parentVC.navigationController?.pushViewController(profileVC, animated: true)
    }
}

//MARK: - UISearchBarDelegate
extension FriendsTableView: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else {
            isSearching = false
            filteredFriends = friends
            tableView.reloadData()
            return
        }
        
        isSearching = true
        filteredFriends = friends.filter { $0.username.lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        filteredFriends = friends
        tableView.reloadData()
    }
}
