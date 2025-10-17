//
//  ProfileViewController.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit

@MainActor
protocol ProfileViewControllerOutput: AnyObject {
    func didRequestGallery()
}

final class ProfileViewController: UIViewController {
    
    private weak var output: ProfileViewControllerOutput?
    private lazy var rootView = ProfileView()
    
    init(output: ProfileViewControllerOutput? = nil) {
        self.output = output
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rootView.setupUI()
        setupActions()
    }
}

private extension ProfileViewController {
    func setupActions() {
        let action = UIAction { [weak self] _ in
            self?.output?.didRequestGallery()
        }
        
        rootView.openGalleryButton.addAction(
            action,
            for: .touchUpInside
        )
    }
}
