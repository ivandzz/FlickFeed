//
//  PlaceholderView.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 14.11.2024.
//

import UIKit

class PlaceholderView: UIView {
    
    //MARK: - Lifecycle
    init(text: String) {
        super.init(frame: .zero)
        
        setupUI(with: text)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Setup
    private func setupUI(with text: String) {
        let placeholderLabel = UILabel()
        placeholderLabel.text          = text
        placeholderLabel.textColor     = .white
        placeholderLabel.textAlignment = .center
        placeholderLabel.font          = .systemFont(ofSize: 16, weight: .semibold)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(placeholderLabel)

        self.backgroundColor = .gray
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
