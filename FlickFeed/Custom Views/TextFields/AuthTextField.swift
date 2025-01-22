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
    
    // MARK: - Lifecycle
    init(fieldType: AuthTextFieldType) {
        super.init(frame: .zero)
        
        setupUI()
        configure(for: fieldType)
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
    
    private func configure(for fieldType: AuthTextFieldType) {
        switch fieldType {
        case .username:
            setPlaceholder(with: "Username")
        case .email:
            setPlaceholder(with: "Email Address")
            self.keyboardType = .emailAddress
            self.textContentType = .emailAddress
        case .loginPassword:
            setPlaceholder(with: "Password")
            self.textContentType = .password
            self.isSecureTextEntry = true
            setupPasswordVisibilityButton()
        case .registerPassword:
            setPlaceholder(with: "Password")
            self.textContentType = .newPassword
            self.isSecureTextEntry = true
            setupPasswordVisibilityButton()
        }
    }
    
    private func setupPasswordVisibilityButton() {
        let button = UIButton()
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .selected)
        button.tintColor = .lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalToConstant: 52),
            containerView.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        containerView.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            button.widthAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        self.rightView = containerView
        self.rightViewMode = .always
        
        button.addTarget(self, action: #selector(showHidePassword), for: .touchUpInside)
    }
    
    // MARK: - Selectors
    @objc private func showHidePassword(_ sender: UIButton) {
        sender.isSelected.toggle()
        self.isSecureTextEntry.toggle()
    }
    
    //MARK: - Helper Functions
    private func setPlaceholder(with text: String) {
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    }
}
