//
//  UserTableCell.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 20.11.2024.
//

import UIKit

class UserTableCell: UITableViewCell {
    
    //MARK: - Variables
    static let identifier = "UserTableCeel"
    
    //MARK: - UI Components
    private let profileImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "person")
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let usernameLabel = FFLabel(font: .systemFont(ofSize: 18, weight: .semibold))
    
    //MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = .black
        
        setupProfileImageView()
        setupUsernameLabel()
    }
    
    private func setupProfileImageView() {
        contentView.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        ])
    }
    
    private func setupUsernameLabel() {
        contentView.addSubview(usernameLabel)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            usernameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    //MARK: - Configuration
    func configure(with user: User) {
        usernameLabel.text = user.username
    }
}
