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
    private let photoFeedFactory = PhotoFeedControllerFactory()
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
        let vc = photoFeedFactory.makeWith(
            tokenStorage: TokenCache(keychain: keychain)
        )
        navigation.setViewControllers([vc], animated: true)
    }
}
