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
        
        self.setTitle(title, for: .normal)
        self.titleLabel?.font = font
        
        self.setTitleColor(.systemBlue, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
