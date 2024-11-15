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
        self.setTitle(title, for: .normal)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        self.backgroundColor    = .systemBlue
        self.titleLabel?.font   = .systemFont(ofSize: 22, weight: .bold)
        self.layer.cornerRadius = 10
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.85),
            self.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
}
