//
//  SelectableImageButton.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 05.11.2024.
//

import UIKit

class SelectableImageButton: UIButton {
    
    //MARK: - Variables
    let size: CGFloat
    let normalImageName: String
    let normalImageColor: UIColor
    let selectedImageName: String
    let selectedImageColor: UIColor
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            self.tintColor = isSelected ? selectedImageColor : normalImageColor
        }
    }
    
    //MARK: - Lifecycle
    init(size: CGFloat, normalImageName: String, normalImageColor: UIColor = .white, selectedImageName: String, selectedImageColor: UIColor = .red) {
        self.size = size
        self.normalImageName = normalImageName
        self.normalImageColor = normalImageColor
        self.selectedImageName = selectedImageName
        self.selectedImageColor = selectedImageColor
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Setup
    private func setupUI() {
        if let normalImage = UIImage(systemName: normalImageName)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: size, weight: .regular)) {
            self.setImage(normalImage, for: .normal)
        }

        if let selectedImage = UIImage(systemName: selectedImageName)?.withConfiguration(UIImage.SymbolConfiguration(pointSize: size, weight: .regular)) {
            self.setImage(selectedImage, for: .selected)
        }
        
        self.imageView?.contentMode = .scaleAspectFit
        self.layer.shadowColor      = UIColor.black.cgColor
        self.layer.shadowOffset     = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity    = 0.7
        self.layer.shadowRadius     = 4
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
