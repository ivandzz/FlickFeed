//
//  SearchVC.swift
//  FlickFeed
//
//  Created by Іван Джулинський on 17.11.2024.
//

import UIKit

class SearchVC: UIViewController {
    
    // MARK: - Variables
    
    
    // MARK: - UI Components
    private let titleLabel = FFLabel(title: "Search for Movies",font: .systemFont(ofSize: 24, weight: .bold))
    
    private let segmentedControl = FFSegmentedControl(items: ["Movies", "Users"])
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .black
        
        setupTitleLabel()
        setupSegmentedControl()
    }
    
    private func setupTitleLabel() {
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupSegmentedControl() {
        view.addSubview(segmentedControl)
        
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    // MARK: - Selectors
    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            titleLabel.text = "Search for Movies"
        case 1:
            titleLabel.text = "Search for Users"
        default:
            break
        }
    }
}

#if DEBUG
import SwiftUI

@available(iOS 13, *)
struct SearchVC_Preview: PreviewProvider {
    static var previews: some View {
        SearchVC().showPreview()
    }
}
#endif
