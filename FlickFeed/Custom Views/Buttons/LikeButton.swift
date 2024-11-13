//
//  LikeButton.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 05.11.2024.
//

import UIKit

class LikeButton: UIButton {
    
    //MARK: - Lifecycle
    init(size: CGFloat) {
        super.init(frame: .zero)
        setupUI(size: size)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Setup
    private func setupUI(size: CGFloat) {
        if let heartImage = UIImage(systemName: "heart")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: size, weight: .regular)) {
            setImage(heartImage, for: .normal)
        }

        if let heartFilledImage = UIImage(systemName: "heart.fill")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: size, weight: .regular)) {
            setImage(heartFilledImage, for: .selected)
        }
        
        tintColor              = .red
        imageView?.contentMode = .scaleAspectFit
        layer.shadowColor      = UIColor.black.cgColor
        layer.shadowOffset     = CGSize(width: 1, height: 1)
        layer.shadowOpacity    = 0.7
        layer.shadowRadius     = 4
        translatesAutoresizingMaskIntoConstraints = false
    }
}
