//
//  ImageButton.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 06.12.2024.
//

import UIKit

class ImageButton: UIButton {
    
    //MARK: - Variables
    
    //MARK: - Lifecycle
    init(imageName: String, size: CGFloat) {
        super.init(frame: .zero)
        
        if let image = UIImage(systemName: imageName)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: size, weight: .regular)) {
            self.setImage(image, for: .normal)
        }
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Setup
    private func setupUI() {

        self.tintColor              = .white
        self.imageView?.contentMode = .scaleAspectFit
        self.layer.shadowColor      = UIColor.black.cgColor
        self.layer.shadowOffset     = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity    = 0.7
        self.layer.shadowRadius     = 4
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
