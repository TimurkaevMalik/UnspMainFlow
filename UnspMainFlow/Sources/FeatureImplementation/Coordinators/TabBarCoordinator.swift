//
//  TabBarCoordinator.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit
import CoreKit
import KeychainStorageKit

@MainActor
protocol TabBarCoordinatorProtocol {
    var tabBarController: UITabBarController { get }
}

final class TabBarCoordinator: TabBarCoordinatorProtocol, CompositionCoordinator {
    
    let tabBarController: UITabBarController = RootTabBarController()
    var children: [Coordinator] = []
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    private let window: UIWindow
    private let keychain: KeychainStorageProtocol
    
    
    init(
        finishDelegate: CoordinatorFinishDelegate? = nil,
        window: UIWindow,
        keychain: KeychainStorageProtocol
    ) {
        self.finishDelegate = finishDelegate
        self.window = window
        self.keychain = keychain
    }
    
    func start() {
        showTabBarController()
    }
}

private extension TabBarCoordinator {
    func showTabBarController() {
        // MARK: - Feed tab
        let feedNav = UINavigationController()
        let feedCoordinator = PhotoFeedCoordinator(
            finishDelegate: self,
            navigation: feedNav,
            keychain: keychain
        )
        feedCoordinator.start()
        
        feedNav.tabBarItem = UITabBarItem(
            title: "Feed",
            image: UIImage(systemName: "photo.on.rectangle"),
            tag: 0
        )
        
        // MARK: - Profile tab
        let profileNav = UINavigationController()
        
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            tag: 1)
        
        // MARK: - TabBarController setup
        tabBarController.setViewControllers(
            [feedNav, profileNav],
            animated: false
        )
        window.rootViewController = tabBarController
        
        children = [feedCoordinator, ]
    }
}
