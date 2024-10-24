//
//  UserTabBarController.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 24/10/24.
//

import UIKit

class UserTabBarController: UITabBarController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        configure()
        configureTabs()
    }
    
    
    private func configure() {
        
        tabBar.tintColor = .white
        tabBar.barTintColor = .black
    }

    private func configureTabs() {
        
        let popularFeed = PopularFeedVC()
        popularFeed.tabBarItem = UITabBarItem(title: "Popular", image: UIImage(systemName: "flame"), tag: 0)
        
        setViewControllers([popularFeed], animated: true)
    }
}
