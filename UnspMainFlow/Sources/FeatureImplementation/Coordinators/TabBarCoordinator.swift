//
//  TabBarCoordinator.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit
import CoreKit
import KeychainStorageKit

final class TabBarCoordinator: CompositionCoordinator {
    
    var children: [Coordinator] = []
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    private let navigation: UINavigationController
    private let keychain: KeychainStorageProtocol
    private let tabBarController = RootTabBarController()
    
    init(
        finishDelegate: CoordinatorFinishDelegate? = nil,
        navigation: UINavigationController,
        keychain: KeychainStorageProtocol
    ) {
        self.finishDelegate = finishDelegate
        self.navigation = navigation
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
        navigation.setViewControllers(
            [tabBarController],
            animated: false
        )
#warning("Set ProfileCoordinator")
        children = [feedCoordinator, ]
    }
}
