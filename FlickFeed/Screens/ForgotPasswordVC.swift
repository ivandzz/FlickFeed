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
        
        signUpButton.addTarget(self, action: #selector(didTapSignUp), for: .touchUpInside)
    }

    // MARK: - UI Setup
    private func setupUI() {
        
        view.backgroundColor = .black
        
        view.addSubview(headerView)
        view.addSubview(emailField)
        view.addSubview(signUpButton)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emailField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailField.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10),

            signUpButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signUpButton.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 30)
        ])
    }
    
    // MARK: - Selectors
    
    @objc private func didTapSignUp() {
        
        let vc = UserTabBarController()
        navigationController?.pushViewController(vc, animated: true)
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
