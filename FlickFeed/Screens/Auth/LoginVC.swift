//
//  LoginVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 30.10.2024.
//

import UIKit

class LoginVC: UIViewController {

    // MARK: - UI Components
    let headerView    = HeaderView(title: "Sign In", subTitle: "Sign in to your account")
    
    let emailField = AuthTextField(fieldType: .email)
    
    let passwordField = AuthTextField(fieldType: .loginPassword)
    
    private lazy var fieldsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [emailField, passwordField])
        stackView.axis         = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment    = .center
        stackView.spacing      = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let signInButton         = FFBigButton(title: "Sign In")

    private let newUserButton        = LabelButton(title: "New user? Create an account.",
                                                   font: .systemFont(ofSize: 18, weight: .semibold))
    
    private let forgotPasswordButton = LabelButton(title: "Forgot password?",
                                                   font: .systemFont(ofSize: 16, weight: .regular))
    
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
            newUserButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 15),
            
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotPasswordButton.topAnchor.constraint(equalTo: newUserButton.bottomAnchor, constant: 5),
        ])
    }
    
    // MARK: - Selectors
    
    @objc private func didTapSignIn() {
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        if !email.isValidEmail {
            AlertManager.showBasicAlert(on: self, title: "Invalid Email", message: "Please enter a valid email.")
            return
        }
        
        if !password.isValidPassword {
            AlertManager.showBasicAlert(on: self, title: "Invalid Password", message: "Please enter a valid password.")
            return
        }
        
        AuthManager.shared.signIn(email: email, password: password) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showBasicAlert(on: self, title: "Error Signing In", message: error.localizedDescription)
            }
            
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.checkAuthentication()
            } else {
                AlertManager.showBasicAlert(on: self, title: "Unknown Signing In Error", message: "Please try again later.")
            }
        }
    }
    
    @objc private func didTapNewUser() {
        let vc = RegisterVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapForgotPassword() {
        let vc = ForgotPasswordVC()
        navigationController?.pushViewController(vc, animated: true)
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
