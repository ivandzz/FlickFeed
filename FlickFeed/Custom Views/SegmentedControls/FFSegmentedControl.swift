//
//  FFSegmentedControl.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 17.11.2024.
//

import UIKit

class FFSegmentedControl: UISegmentedControl {
    
    // MARK: - Lifecycle
    init(items: [String]) {
        super.init(items: items)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.selectedSegmentIndex     = 0
        self.backgroundColor          = .black
        self.selectedSegmentTintColor = .white
        let selectedTextAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black]
        let normalTextAttributes: [NSAttributedString.Key: Any]   = [.foregroundColor: UIColor.white]
        self.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        self.setTitleTextAttributes(normalTextAttributes, for: .normal)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
