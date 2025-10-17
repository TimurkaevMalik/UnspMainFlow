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
    
    private let navigation: UINavigationController
    private let keychain: KeychainStorageProtocol
    
    
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
        
        let profileCoordinator = ProfileFeedCoordinator(
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
        navigation.setViewControllers(
            [tabBarController],
            animated: true
        )
        
        children = [feedCoordinator, profileCoordinator]
        
#warning("Можно ли так скрывать NavigationBar у TabBarController или лучше передавать его в window? Дело в том. что я кладу tabBarController в navigation, но и дочерние контроллеры у tabBarController имеют свои UINavigationController - и получается у меня два navigationBar на экране")
        navigation.setNavigationBarHidden(true, animated: false)
        feedNav.setNavigationBarHidden(true, animated: false)
        profileNav.setNavigationBarHidden(true, animated: false)
    }
}
