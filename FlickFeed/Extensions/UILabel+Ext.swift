//
//  UILabel+Ext.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 13.11.2024.
//

import UIKit

extension UILabel {
    
    func setText(_ text: String, textColor: UIColor? = .white, prependedBySymbolNamed symbolSystemName: String, imageTintColor: UIColor? = .white, font: UIFont? = nil) {
        if let font { self.font = font }
        
        let symbolConfiguration = UIImage.SymbolConfiguration(font: self.font)
        var symbolImage = UIImage(systemName: symbolSystemName, withConfiguration: symbolConfiguration)?.withRenderingMode(.alwaysTemplate)
        symbolImage = symbolImage?.withTintColor(imageTintColor ?? .white, renderingMode: .alwaysOriginal)
        
        let symbolTextAttachment = NSTextAttachment()
        symbolTextAttachment.image = symbolImage
        
        let attributedText = NSMutableAttributedString()
        attributedText.append(NSAttributedString(attachment: symbolTextAttachment))
        
        let text = NSAttributedString(string: " " + text, attributes: [.foregroundColor: UIColor.white])
        attributedText.append(text)
        
        self.attributedText = attributedText
    }
}
