//
//  BackgroundLabel.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 14.11.2024.
//

import UIKit

class BackgroundLabel: UILabel {
    
    //MARK: - Variables
    var padding: UIEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
    
    //MARK: - Lifecycle
    init(text: String? = "", font: UIFont?, alignment: NSTextAlignment = .center, backgroundColor: UIColor = .systemBlue) {
        super.init(frame: .zero)
        
        self.text            = text
        self.backgroundColor = backgroundColor
        self.font            = font
        self.textAlignment   = alignment
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right, height: size.height + padding.top + padding.bottom)
    }
    
    private func setupUI() {
        self.textColor                 = .white
        self.layer.cornerRadius        = 8
        self.numberOfLines             = 1
        self.layer.masksToBounds       = true
        self.adjustsFontSizeToFitWidth = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
