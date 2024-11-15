//
//  UserTabBarController.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 24/10/24.
//

import UIKit
import FirebaseAuth

class UserTabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        tabBar.tintColor    = .white
        tabBar.barTintColor = .black
        
        configureTabs()
    }
    
    private func configureTabs() {
        
        let popularFeed = PopularFeedVC()
        popularFeed.tabBarItem = UITabBarItem(title: "Popular", image: UIImage(systemName: "flame"), tag: 0)
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        let account = ProfileVC(userUID: uid, isCurrentUser: true)
        account.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 1)
        
        setViewControllers([popularFeed, account], animated: true)
    }
}
