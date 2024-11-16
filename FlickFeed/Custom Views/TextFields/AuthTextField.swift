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
            self.attributedPlaceholder = NSAttributedString(string: "Username", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
        case .email:
            self.attributedPlaceholder = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            self.keyboardType          = .emailAddress
            self.textContentType       = .emailAddress
            
        case .loginPassword:
            self.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            self.textContentType       = .password
            self.isSecureTextEntry     = true
            
        case .registerPassword:
            self.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            self.textContentType       = .newPassword
            self.isSecureTextEntry     = true
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.textColor              = .white
        self.tintColor              = .white
        self.textAlignment          = .left
        self.layer.cornerRadius     = 10
        self.backgroundColor        = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
        self.leftView               = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        self.leftViewMode           = .always
        self.autocapitalizationType = .none
        self.autocorrectionType     = .no
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.85),
            self.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
}
