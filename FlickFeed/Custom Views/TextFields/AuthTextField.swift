//
//  AuthTextField.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 31.10.2024.
//

import UIKit

class AuthTextField: UITextField {
    
    // MARK: - Variables
    enum AuthTextFieldType {
        case username
        case email
        case loginPassword
        case registerPassword
    }
    
    private let authFieldType: AuthTextFieldType
    
    // MARK: - Lifecycle
    init(fieldType: AuthTextFieldType) {
        
        authFieldType = fieldType
        super.init(frame: .zero)
        setupUI()
        
        switch fieldType {
        case .username:
            attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        case .email:
            attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            keyboardType = .emailAddress
            textContentType = .emailAddress
        case .loginPassword:
            attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            textContentType = .password
            isSecureTextEntry = true
        case .registerPassword:
            attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            textContentType = .newPassword
            isSecureTextEntry = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        textColor = .white
        tintColor = .white
        textAlignment = .left
        layer.cornerRadius = 10
        backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        leftViewMode = .always
        autocapitalizationType = .none
        autocorrectionType = .no
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.85),
            heightAnchor.constraint(equalToConstant: 55)
        ])
    }
}
