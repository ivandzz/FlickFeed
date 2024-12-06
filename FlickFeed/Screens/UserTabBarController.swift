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
        popularFeed.tabBarItem = UITabBarItem(
            title: "Popular",
            image: UIImage(systemName: "flame"),
            selectedImage: UIImage(systemName: "flame.fill")
        )

        let searchNavigation = UINavigationController(rootViewController: SearchVC())
        searchNavigation.navigationBar.barTintColor = .black
        searchNavigation.tabBarItem = UITabBarItem(
            title: "Search",
            image: UIImage(systemName: "magnifyingglass"),
            selectedImage: UIImage(systemName: "sparkle.magnifyingglass")
        )

        let accountNavigation = UINavigationController(rootViewController: ProfileVC())
        accountNavigation.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        setViewControllers([popularFeed, searchNavigation, accountNavigation], animated: true)
    }
}
