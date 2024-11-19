//
//  ForgotPasswordVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 31.10.2024.
//

import UIKit

class ForgotPasswordVC: UIViewController {
    
    // MARK: - UI Components
    let headerView           = HeaderView(title: "Forgot Password", subTitle: "Reset your password")
    
    let emailField           = AuthTextField(fieldType: .email)
    
    private let signUpButton = FFBigButton(title: "Sign Up")
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupHeaderView()
        setupEmailField()
        setupSignUpButton()
    }
    
    private func setupHeaderView() {
        view.addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupEmailField() {
        view.addSubview(emailField)
        emailField.delegate = self
        
        NSLayoutConstraint.activate([
            emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10)
        ])
    }
    
    private func setupSignUpButton() {
        view.addSubview(signUpButton)
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 30)
        ])
    }
    
    // MARK: - Selectors
    @objc private func didTapSignUp() {
        let email = emailField.text ?? ""
        
        if !email.isValidEmail {
            AlertManager.showBasicAlert(on: self, title: "Invalid Email", message: "Please enter a valid email.")
        }
        
        AuthManager.shared.forgotPassword(email: email) { [weak self] error in
            guard let self else { return }
            
            if let error {
                AlertManager.showBasicAlert(on: self, title: "Error Sending Password Reset", message: error.localizedDescription)
                return
            }
            
            AlertManager.showBasicAlert(on: self, title: "Password Reset send", message: nil)
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - UITextFieldDelegate
extension ForgotPasswordVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            textField.resignFirstResponder()
            didTapSignUp()
        }
        return true
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct ForgotPasswordVC_Preview: PreviewProvider {
    static var previews: some View {
        ForgotPasswordVC().showPreview()
    }
}
#endif
