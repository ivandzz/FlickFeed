//
//  FFBigButton.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 31.10.2024.
//

import UIKit

class FFBigButton: UIButton {

    // MARK: - Lifecycle
    init(title: String) {
        
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        backgroundColor    = .systemBlue
        titleLabel?.font   = .systemFont(ofSize: 22, weight: .bold)
        layer.cornerRadius = 10
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.85),
            heightAnchor.constraint(equalToConstant: 55)
        ])
    }
}
