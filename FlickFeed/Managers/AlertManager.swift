//
//  AlertManager.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 01.11.2024.
//

import UIKit

final class AlertManager {
    
    public static func showBasicAlert(on vc: UIViewController, title: String, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            vc.present(alert, animated: true)
        }
    }
}
