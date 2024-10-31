//
//  LabelButton.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 31.10.2024.
//

import UIKit

class LabelButton: UIButton {

    // MARK: - Lifecycle
    init(title: String, font: UIFont) {
        
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        titleLabel?.font = font
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        
        setTitleColor(.systemBlue, for: .normal)
        translatesAutoresizingMaskIntoConstraints = false
    }
}
