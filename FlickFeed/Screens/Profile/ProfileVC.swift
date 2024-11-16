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
    private let userUID: String
    private let isCurrentUser: Bool
    private var isLoading = false {
        didSet {
            isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - UI Components
    private let titleLabel = FFLabel(font: .systemFont(ofSize: 24, weight: .bold))
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Likes", "Friends"]
        let sc = UISegmentedControl(items: items)
        sc.selectedSegmentIndex     = 0
        sc.backgroundColor          = .black
        sc.selectedSegmentTintColor = .white
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        let normalTextAttributes: [NSAttributedString.Key: Any]   = [.foregroundColor: UIColor.white]
        sc.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        sc.setTitleTextAttributes(normalTextAttributes, for: .normal)
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let likesCollectionView = LikesCollectionView()
    
    private let activityIndicator = FFActivityIndicator()
    
    // MARK: - Lifecycle
    init(userUID: String, isCurrentUser: Bool = false) {
        self.isCurrentUser = isCurrentUser
        self.userUID = userUID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchUser(userUID: userUID)
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
        setupSegmentedElements()
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
    
    private func setupSegmentedElements() {
        view.addSubview(likesCollectionView)
        
        NSLayoutConstraint.activate([
            likesCollectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            likesCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            likesCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            likesCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    // MARK: - Selectors
    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            likesCollectionView.isHidden = false
        case 1:
            likesCollectionView.isHidden = true
        default:
            break
        }
    }
    
    //MARK: - Configuration
    private func configureHeader() {
        if let user = user {
            titleLabel.text = isCurrentUser ? "Welcome, " + user.username : user.username + "'s Profile"
        }
    }
    
    //MARK: - Firebase Methods
    private func fetchUser(userUID: String) {
        isLoading = true
        AuthManager.shared.fetchUser(with: userUID) { [weak self] user, error in
            guard let self = self else { return }
            isLoading = false
            
            if let error = error {
                AlertManager.showBasicAlert(on: self, title: "Something went wrong", message: error.localizedDescription)
                return
            }
            
            if let user = user {
                self.user = user
                self.configureHeader()
                likesCollectionView.getMovies(with: user.likedMovies)
            }
        }
    }
}
