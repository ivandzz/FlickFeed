//
//  RegisterVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 31.10.2024.
//

import UIKit

class RegisterVC: UIViewController {

    // MARK: - UI Components
    let headerView    = HeaderView(title: "Sign Up", subTitle: "Create your account")
    
    let usernameField = AuthTextField(fieldType: .username)
    
    let emailField    = AuthTextField(fieldType: .email)
    
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

    // MARK: - UI Setup
    private func setupUI() {
        
        view.backgroundColor = .black
        
        view.addSubview(headerView)
        view.addSubview(fieldsStack)
        view.addSubview(signUpButton)
        view.addSubview(signInButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        usernameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
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
            signInButton.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 15)
        ])
    }
    
    // MARK: - Selectors
    
    //TODO: - Error handling
    @objc private func didTapSignUp() {
        let username = usernameField.text ?? ""
        let email = emailField.text ?? ""
        let password = passwordField.text ?? ""
        
        if !username.isValidUsername {
            AlertManager.showBasicAlert(on: self, title: "Invalid Username", message: "Please enter a valid username.")
            return
        }
        
        if !email.isValidEmail {
            AlertManager.showBasicAlert(on: self, title: "Invalid Email", message: "Please enter a valid email.")
            return
        }
        
        if !password.isValidPassword {
            AlertManager.showBasicAlert(on: self, title: "Invalid Password", message: "Please enter a valid password.")
            return
        }
        
        AuthManager.shared.registerUser(username: username, email: email, password: password) { [weak self] wasRegistered, error in
            guard let self = self else { return }
            
            if let error = error {
                AlertManager.showBasicAlert(on: self, title: "Error Signing Up", message: error.localizedDescription)
                return
            }
            
            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                sceneDelegate.checkAuthentication()
            } else {
                AlertManager.showBasicAlert(on: self, title: "Unknown Signing Up Error", message: "Please try again later.")
            }
        }
    }
    
    @objc private func didTapSignIn() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension RegisterVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            textField.resignFirstResponder()
            didTapSignUp()
        }
        return true
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
