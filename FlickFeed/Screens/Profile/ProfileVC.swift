//
//  AccountVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 04.11.2024.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController {
    
    // MARK: - Variables
    private var user: User?
    private let isCurrentUser: Bool
    
    // MARK: - UI Components
    private let titleLabel = FFLabel(font: .systemFont(ofSize: 24, weight: .bold))
    
    // MARK: - Lifecycle
    init(userUID: String, isCurrentUser: Bool = false) {
        self.isCurrentUser = isCurrentUser
        super.init(nibName: nil, bundle: nil)
        fetchUser(userUID: userUID)
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
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        ])
        
        setupHeader()
    }
    
    private func setupHeader() {
        if let user = user {
            titleLabel.text = isCurrentUser ? "Welcome, " + user.username : user.username + "'s Profile"
        }
    }
    // MARK: - Selectors
    
    //MARK: - Helpers
    private func fetchUser(userUID: String) {
        AuthManager.shared.fetchUser(with: userUID) { [weak self] user, error in
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showBasicAlert(on: self, title: "Something went wrong", message: error.localizedDescription)
                return
            }
            
            if let user = user {
                self.user = user
            }
        }
    }
}
