//
//  PhotoFeedCoordinator.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit
import CoreKit
import KeychainStorageKit

final class PhotoFeedCoordinator: Coordinator {
    
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
        showPhotoFeedScreen()
    }
}

private extension PhotoFeedCoordinator {
    func showPhotoFeedScreen() {
        let vc = PhotoSearchFeedControllerFactory().makeWith(
            tokenStorage: TokenCache(keychain: keychain),
            output: self
        )
        navigation.setViewControllers([vc], animated: true)
    }
}

extension PhotoFeedCoordinator: ImageCollectionControllerOutput {
    func didSelect(image: UIImage, data: PhotoItem) {
        let vc = PhotoInfoControllerFactory().makeWith(
            tokenStorage: TokenCache(keychain: keychain),
            photoItem: data,
            image: image
        )
        
        vc.hidesBottomBarWhenPushed = true
        navigation.pushViewController(vc, animated: true)
        navigation.setNavigationBarHidden(false, animated: false)
    }
}
