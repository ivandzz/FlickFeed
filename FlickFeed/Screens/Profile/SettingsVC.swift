//
//  SettingsVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 06.12.2024.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SettingsVC: UIViewController {
    
    // MARK: - Variables
    private let user: User
    
    // MARK: - UI Components
    private let titleLabel             = FFLabel(title: "Settings", font: .systemFont(ofSize: 24, weight: .bold))
    private let usernameLabel          = FFLabel(title: "Username", font: .systemFont(ofSize: 14, weight: .thin))
    private let usernameField          = AuthTextField(fieldType: .username)
    private let updateUsernameButton   = FFBigButton(title: "Update Username", font: .systemFont(ofSize: 22, weight: .medium))
    private let resetPopularFeedLabel  = FFLabel(title: "Reser Your Popular Feed", font: .systemFont(ofSize: 14, weight: .thin))
    private let resetPopularFeedButton = FFBigButton(title: "Reset", font: .systemFont(ofSize: 22, weight: .medium))
    private let signOutLabel           = FFLabel(title: "Sign Out From Your Account", font: .systemFont(ofSize: 14, weight: .thin))
    private let signOutButton          = FFBigButton(title: "Sign Out", font: .systemFont(ofSize: 22, weight: .medium))
    
    // MARK: - Lifecycle
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
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
        
        setupTitleLabel()
        setupUsernameLabel()
        setupUsernameField()
        setupUpdateUsernameButton()
        setupResetPopularFeedLabel()
        setupResetPopularFeedButton()
        setupSignOutLabel()
        setupSignOutButton()
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupUsernameLabel() {
        view.addSubview(usernameLabel)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupUsernameField() {
        view.addSubview(usernameField)
        
        usernameField.text = user.username
        
        NSLayoutConstraint.activate([
            usernameField.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 10),
            usernameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupUpdateUsernameButton() {
        view.addSubview(updateUsernameButton)
        
        updateUsernameButton.addTarget(self, action: #selector(updateUsernameButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            updateUsernameButton.topAnchor.constraint(equalTo: usernameField.bottomAnchor, constant: 20),
            updateUsernameButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            updateUsernameButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupResetPopularFeedLabel() {
        view.addSubview(resetPopularFeedLabel)
        
        NSLayoutConstraint.activate([
            resetPopularFeedLabel.topAnchor.constraint(equalTo: updateUsernameButton.bottomAnchor, constant: 20),
            resetPopularFeedLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resetPopularFeedLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupResetPopularFeedButton() {
        view.addSubview(resetPopularFeedButton)
        
        resetPopularFeedButton.addTarget(self, action: #selector(resetPopularFeedButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            resetPopularFeedButton.topAnchor.constraint(equalTo: resetPopularFeedLabel.bottomAnchor, constant: 10),
            resetPopularFeedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resetPopularFeedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupSignOutLabel() {
        view.addSubview(signOutLabel)
        
        NSLayoutConstraint.activate([
            signOutLabel.topAnchor.constraint(equalTo: resetPopularFeedButton.bottomAnchor, constant: 20),
            signOutLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signOutLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupSignOutButton() {
        view.addSubview(signOutButton)
        
        signOutButton.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            signOutButton.topAnchor.constraint(equalTo: signOutLabel.bottomAnchor, constant: 10),
            signOutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signOutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Selectors
    @objc private func updateUsernameButtonTapped() {
        guard let newUsername = usernameField.text else { return }
        
        if !newUsername.isValidUsername {
            AlertManager.showBasicAlert(on: self, title: "Invalid Username", message: "Please enter a valid username.")
            return
        }
        
        if newUsername == user.username {
            AlertManager.showBasicAlert(on: self, title: "Same Username", message: "Please enter a new username.")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(user.userUID).updateData(["username": newUsername]) { error in
            if let error {
                AlertManager.showBasicAlert(on: self, title: "Error Updating Username", message: error.localizedDescription)
            }
            
            if let profileVC = self.navigationController?.viewControllers.first as? ProfileVC {
                profileVC.fetchUser()
                AlertManager.showBasicAlert(on: self, title: "Success", message: "Username updated successfully.")
            } else {
                AlertManager.showBasicAlert(on: self, title: "Error Updating Username", message: "Please try again later or reload app.")
            }
        }
            
    }
    
    @objc private func resetPopularFeedButtonTapped() {
        if let tabBar = self.tabBarController, let popularFeedVC = tabBar.viewControllers?.first as? PopularFeedVC {
            popularFeedVC.resetFeed()
            AlertManager.showBasicAlert(on: self, title: "Success", message: "Popular feed reset successfully.")
        } else {
            AlertManager.showBasicAlert(on: self, title: "Error Resetting Feed", message: "Please try again later.")
        }
    }
    
    @objc private func signOutButtonTapped() {
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
}
