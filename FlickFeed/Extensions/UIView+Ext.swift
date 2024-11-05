//
//  UIView+Ext.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 05.11.2024.
//

import UIKit

extension UIView {
    
    func getParentVC() -> UIViewController? {
        var responder: UIResponder? = self
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIViewController {
                return viewController
            }
            responder = nextResponder
        }
        return nil
    }
}
