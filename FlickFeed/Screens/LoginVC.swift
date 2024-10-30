//
//  LoginVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 30.10.2024.
//

import UIKit

class LoginVC: UIViewController {

    // MARK: - UI Components
    let logoImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "movieclapper")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.text = "Sign In"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.text = "Sign in to your account"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var headerStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoImageView, titleLabel, subTitleLabel])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let usernameField: UITextField = {
        let tf = UITextField()
        tf.textColor = .white
        tf.tintColor = .white
        tf.textAlignment = .left
        tf.layer.cornerRadius = 10
        tf.backgroundColor = .darkGray
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 50))
        tf.leftViewMode = .always
        tf.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let passwordField: UITextField = {
        let tf = UITextField()
        tf.textColor = .white
        tf.tintColor = .white
        tf.textAlignment = .left
        tf.layer.cornerRadius = 10
        tf.backgroundColor = .darkGray
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 50))
        tf.leftViewMode = .always
        tf.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.textContentType = .password
        tf.isSecureTextEntry = true
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private lazy var fieldsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [usernameField, passwordField])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
        
        view.addSubview(headerStack)
        view.addSubview(fieldsStack)
        view.addSubview(signInButton)
        view.addSubview(newUserButton)
        view.addSubview(forgotPasswordButton)
        
        NSLayoutConstraint.activate([
            headerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            headerStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            
            logoImageView.widthAnchor.constraint(equalToConstant: 90),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor),
            
            fieldsStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            fieldsStack.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 30),
            
            usernameField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            usernameField.heightAnchor.constraint(equalToConstant: 55),

            passwordField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            passwordField.heightAnchor.constraint(equalToConstant: 55),
            
            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.topAnchor.constraint(equalTo: fieldsStack.bottomAnchor, constant: 30),
            signInButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            signInButton.heightAnchor.constraint(equalToConstant: 55),
            
            newUserButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            newUserButton.topAnchor.constraint(equalTo: signInButton.bottomAnchor, constant: 10),
            
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forgotPasswordButton.topAnchor.constraint(equalTo: newUserButton.bottomAnchor, constant: 5),
        ])
    }
    
    // MARK: - Selectors
    
    @objc private func didTapSignIn() {
        let vc = PopularFeedVC()
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
