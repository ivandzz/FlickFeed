//
//  ProfileVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 04.11.2024.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    // MARK: - Variables
    private var user: User?
    private var userUID: String
    
    private var isCurrentUser: Bool {
        userUID == Auth.auth().currentUser?.uid ? true : false
    }
    
    private var isLoading = false {
        didSet {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - UI Components
    private let titleLabel               = FFLabel(font: .systemFont(ofSize: 24, weight: .bold))
    private lazy var settingsButton      = ImageButton(imageName: "gear", size: 25)
    private lazy var friendButton        = SelectableImageButton(size: 25, normalImageName: "person.badge.plus", selectedImageName: "person.badge.minus")
    private let segmentedControl         = FFSegmentedControl(items: ["Likes", "Friends"])
    private lazy var likesCollectionView = LikesCollectionView()
    private lazy var friendsTableView    = FriendsTableView()
    private let activityIndicator        = FFActivityIndicator()
    
    // MARK: - Lifecycle
    init() {
        self.userUID = Auth.auth().currentUser?.uid ?? ""
        super.init(nibName: nil, bundle: nil)
        
        fetchUser(userUID: userUID)
    }

    init(user: User) {
        self.user = user
        self.userUID = user.userUID
        super.init(nibName: nil, bundle: nil)
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.configureHeader()
            self.likesCollectionView.fetchMovies(with: user.likedMovies)
            self.friendsTableView.fetchFriends(with: user.friends)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        setupHeader()
        setupSegmentedControl()
        setupLikesCollectionView()
        setupActivityIndicator()
    }
    
    private func setupHeader() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupSegmentedControl() {
        view.addSubview(segmentedControl)
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupLikesCollectionView() {
        view.addSubview(likesCollectionView)
        
        NSLayoutConstraint.activate([
            likesCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            likesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            likesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            likesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupFriendsTableView() {
        view.addSubview(friendsTableView)
        
        NSLayoutConstraint.activate([
            friendsTableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            friendsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            friendsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            friendsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupSettingsButton() {
        view.addSubview(settingsButton)
        
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            settingsButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupFriendButton() {
        view.addSubview(friendButton)
        
        checkIfFriend()
        
        friendButton.addTarget(self, action: #selector(friendButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            friendButton.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            friendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Selectors
    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            friendsTableView.removeFromSuperview()
            setupLikesCollectionView()
        case 1:
            likesCollectionView.removeFromSuperview()
            setupFriendsTableView()
        default:
            break
        }
    }
    
    @objc private func settingsButtonTapped() {
        AuthManager.shared.signOut { error in
            if let error {
                AlertManager.showBasicAlert(on: self, title: "Error Signing Out", message: error.localizedDescription)
            }
            
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.checkAuthentication()
            } else {
                AlertManager.showBasicAlert(on: self, title: "Unknown Signing Out Error", message: "Please try again later.")
            }
        }
    }

    @objc private func friendButtonTapped() {
        friendButton.isSelected.toggle()
        
        SocialManager.shared.updateFriend(for: userUID) { error in
            if let error {
                AlertManager.showBasicAlert(on: self, title: "Error Updating Friendship", message: error.localizedDescription)
            }
        }
    }
    
    //MARK: - Configuration
    private func configureHeader() {
        if let user {
            titleLabel.text = isCurrentUser ? "Welcome, " + user.username : user.username + "'s Profile"
            isCurrentUser ? setupSettingsButton() : setupFriendButton()
        }
    }
    
    private func checkIfFriend() {
        SocialManager.shared.checkIfFriend(friendUID: userUID) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let isFriend):
                self.friendButton.isSelected = isFriend
            case .failure(let error):
                AlertManager.showBasicAlert(on: self, title: "Error Checking Friendship", message: error.localizedDescription)
            }
        }
    }
    
    //MARK: - Firebase Methods
    private func fetchUser(userUID: String) {
        isLoading = true
        
        AuthManager.shared.fetchUser(with: userUID) { [weak self] user, error in
            guard let self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error {
                    AlertManager.showBasicAlert(on: self, title: "Error Fetching User", message: error.localizedDescription)
                    return
                }
                
                if let user {
                    self.user = user
                    self.configureHeader()
                    self.likesCollectionView.fetchMovies(with: user.likedMovies)
                    self.friendsTableView.fetchFriends(with: user.friends)
                }
            }
        }
    }
}
