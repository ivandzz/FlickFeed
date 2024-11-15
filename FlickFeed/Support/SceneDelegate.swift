//
//  SceneDelegate.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 22/10/24.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        setupWindow(with: scene)
        checkAuthentication()
    }
    
    private func setupWindow(with scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        self.window?.makeKeyAndVisible()
    }
    
    public func checkAuthentication() {
        if Auth.auth().currentUser == nil {
            let vc = LoginVC()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            presentVC(with: nav)
        } else {
            presentVC(with: UserTabBarController())
        }
    }
    
    private func presentVC(with viewController: UIViewController) {
        DispatchQueue.main.async { [weak self] in
            UIView.animate(withDuration: 0.25) {
                self?.window?.layer.opacity = 0
            } completion: { [weak self] _ in
                self?.window?.rootViewController = viewController
                UIView.animate(withDuration: 0.25) { [weak self] in
                    self?.window?.layer.opacity = 1
                }
            }
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        CoreDataManager.shared.saveContext()
    }
}
