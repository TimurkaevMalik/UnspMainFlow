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
protocol TabBarCoordinatorProtocol: CompositionCoordinator {
    var tabBarController: UITabBarController { get }
}

final class TabBarCoordinator: TabBarCoordinatorProtocol {
    
    let tabBarController: UITabBarController = RootTabBarController()
    var children: [Coordinator] = []
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    private let keychain: KeychainStorageProtocol
    
    
    init(
        finishDelegate: CoordinatorFinishDelegate? = nil,
        keychain: KeychainStorageProtocol
    ) {
        self.finishDelegate = finishDelegate
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
        
        let profileCoordinator = ProfileFlowCoordinator(
            finishDelegate: self,
            navigation: profileNav,
            keychain: keychain
        )
        profileCoordinator.start()
        
        profileNav.tabBarItem = UITabBarItem(
            title: "Profile",
            image: UIImage(systemName: "person"),
            tag: 1)
        
        // MARK: - TabBarController setup
        tabBarController.setViewControllers(
            [feedNav, profileNav],
            animated: false
        )

        children = [feedCoordinator, profileCoordinator]
        
        feedNav.setNavigationBarHidden(false, animated: false)
        profileNav.setNavigationBarHidden(true, animated: false)
    }
}
