//
//  LoginVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 30.10.2024.
//

import UIKit

class LoginVC: UIViewController {

    // MARK: - UI Components
    let headerView = HeaderView(title: "Sign In", subTitle: "Sign in to your account")
    
    let usernameField = AuthTextField(fieldType: .username)
    
    let passwordField = AuthTextField(fieldType: .loginPassword)
    
    private lazy var fieldsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [usernameField, passwordField])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let signInButton = FFBigButton(title: "Sign In")
    
    private let newUserButton: UIButton = {
        let button = UIButton()
        button.setTitle("New user? Create account.", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot password?", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupUI()
        
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        newUserButton.addTarget(self, action: #selector(didTapNewUser), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        view.backgroundColor = .black
        
        view.addSubview(headerView)
        view.addSubview(fieldsStack)
        view.addSubview(signInButton)
        view.addSubview(newUserButton)
        view.addSubview(forgotPasswordButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            fieldsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fieldsStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),

            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.topAnchor.constraint(equalTo: fieldsStack.bottomAnchor, constant: 30),
            
            newUserButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newUserButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 10),
            
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotPasswordButton.topAnchor.constraint(equalTo: newUserButton.bottomAnchor, constant: 5),
        ])
    }
    
    // MARK: - Selectors
    
    @objc private func didTapSignIn() {
        
        let vc = UserTabBarController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapNewUser() {
        
        let vc = RegisterVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapForgotPassword() {
        
        let vc = ForgotPasswordVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct LoginVc_Preview: PreviewProvider {
    static var previews: some View {
        LoginVC().showPreview()
    }
}
#endif
