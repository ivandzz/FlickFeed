//
//  FFSearchBar.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 16.11.2024.
//

import UIKit

class FFSearchBar: UISearchBar {
    
    //MARK: - Lifecycle
    init(placeholder: String) {
        super.init(frame: .zero)
        self.searchTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        self.barTintColor                    = .clear
        self.tintColor                       = .white
        self.searchBarStyle                  = .minimal
        self.backgroundColor                 = .clear
        self.searchTextField.textColor       = .white
        self.searchTextField.backgroundColor = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
