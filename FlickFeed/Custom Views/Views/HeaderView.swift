//
//  HeaderView.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 31.10.2024.
//

import UIKit

class HeaderView: UIView {
    
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
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var headerStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoImageView, titleLabel, subTitleLabel])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - LifeCycle
    init(title: String, subTitle: String) {
        
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.subTitleLabel.text = subTitle
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        addSubview(headerStack)
        
        NSLayoutConstraint.activate([
            headerStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            headerStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20),
            
            logoImageView.widthAnchor.constraint(equalToConstant: 90),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor),
        ])
    }
}
