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
    private let titleLabel            = FFLabel(title: "Search for Movies",font: .systemFont(ofSize: 24, weight: .bold))
    
    private let segmentedControl      = FFSegmentedControl(items: ["Movies", "Users"])
    private lazy var movieTableView   = MoviesTableView()
    private lazy var userTableView    = UsersTableView()
    
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
        setupMovieTableViewConstraints()
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

    private func setupMovieTableViewConstraints() {
        view.addSubview(movieTableView)
        NSLayoutConstraint.activate([
            movieTableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            movieTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            movieTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            movieTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupUserTableViewConstraints() {
        view.addSubview(userTableView)
        NSLayoutConstraint.activate([
            userTableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            userTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    
    // MARK: - Selectors
    @objc private func segmentChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            titleLabel.text = "Search for Movies"

            userTableView.removeFromSuperview()
            setupMovieTableViewConstraints()
        case 1:
            titleLabel.text = "Search for Users"

            movieTableView.removeFromSuperview()
            setupUserTableViewConstraints()
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
