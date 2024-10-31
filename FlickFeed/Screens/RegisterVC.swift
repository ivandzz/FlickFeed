//
//  RegisterVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 31.10.2024.
//

import UIKit

class RegisterVC: UIViewController {

    // MARK: - UI Components
    let headerView = HeaderView(title: "Sign Up", subTitle: "Create your account")
    
    let usernameField = AuthTextField(fieldType: .username)
    
    let emailField = AuthTextField(fieldType: .email)
    
    let passwordField = AuthTextField(fieldType: .registerPassword)
    
    private lazy var fieldsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [usernameField, emailField, passwordField])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let signUpButton = FFBigButton(title: "Sign Up")
    
    private let signInButton = LabelButton(title: "Already have an account? Sign In.",
                                           font: .systemFont(ofSize: 18, weight: .semibold))
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupUI()
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
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
        view.addSubview(signUpButton)
        view.addSubview(signInButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            fieldsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fieldsStack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),

            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: fieldsStack.bottomAnchor, constant: 30),
            
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 15),
        ])
    }
    
    // MARK: - Selectors
    
    @objc private func didTapSignUp() {
        
        let vc = UserTabBarController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapSignIn() {
        
        navigationController?.popToRootViewController(animated: true)
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct RegisterVc_Preview: PreviewProvider {
    static var previews: some View {
        RegisterVC().showPreview()
    }
}
#endif
