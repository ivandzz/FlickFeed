//
//  FFActivityIndicator.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 05.11.2024.
//

import UIKit

class FFActivityIndicator: UIActivityIndicatorView {
    
    // MARK: - Lifecycle
    init() {
        super.init(style: .large)
        
        self.color = .white
        self.hidesWhenStopped = true
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
