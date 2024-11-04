//
//  FFLabel.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 04.11.2024.
//

import UIKit

class FFLabel: UILabel {
    
    //MARK: - Lifecycle
    init(title: String = "", font: UIFont, alignment: NSTextAlignment = .left, lines: Int = 0) {
        super.init(frame: .zero)
        self.text          = title
        self.font          = font
        self.textAlignment = alignment
        self.numberOfLines = lines
        self.textColor     = .white
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
