//
//  ProfileFlowCoordinator.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit
import CoreKit
import KeychainStorageKit

final class ProfileFlowCoordinator: Coordinator {
    
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    private let navigation: UINavigationController
    private let keychain: KeychainStorageProtocol
    private let profileControllerFactory = ProfileControllerFactory()
    private let photoInfoControllerFactory = PhotoInfoControllerFactory()
    
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
        showProfileScreen()
    }
}

private extension ProfileFlowCoordinator {
    func showProfileScreen() {
        let vc = ProfileViewController(output: self)
        navigation.setViewControllers([vc], animated: true)
    }
    
    func showFavoriteImagesScreen() {
        let vc = profileControllerFactory.makeWith(
            tokenStorage: TokenCache(keychain: keychain),
            output: self
        )
        push(vc)
    }
    
    func push(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        navigation.pushViewController(vc, animated: true)
        navigation.setNavigationBarHidden(false, animated: false)
    }
}

extension ProfileFlowCoordinator: ImageCollectionControllerOutput {
    func didSelect(image: UIImage, data: PhotoItem) {
        let vc = photoInfoControllerFactory.makeWith(
            tokenStorage: TokenCache(keychain: keychain),
            photoItem: data,
            image: image
        )
        push(vc)
    }
}

extension ProfileFlowCoordinator: ProfileViewControllerOutput {
    func didRequestGallery() {
        showFavoriteImagesScreen()
    }
}
