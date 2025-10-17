//
//  RootUnspMainFlowCoordinator.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit
import CoreKit
import KeychainStorageKit
import HelpersSharedUnsp

final class RootUnspMainFlowCoordinator: FlowCoordinator {
    
    var child: Coordinator?
    weak var finishDelegate: CoordinatorFinishDelegate?
    
    private let window: UIWindow
    private let keychainFactory: KeychainStorageFactory
    
    init(
        finishDelegate: CoordinatorFinishDelegate? = nil,
        window: UIWindow,
        keychainFactory: KeychainStorageFactory = KeychainStorageFactory()
    ) {
        self.finishDelegate = finishDelegate
        self.window = window
        self.keychainFactory = keychainFactory
    }
    
    func start() {
#warning("remove ValetStorage")
        let keychain = ValetStorage(id: " ", accessibility: .whenUnlockedThisDeviceOnly, logger: nil)
        
#warning("Set makeAuthorizedKeychain()")
        if let keychain  {
            child = TabBarCoordinator(
                finishDelegate: self,
                window: window,
                keychain: keychain
            )
            
            child?.start()
        } else {
            print("finish")
            finish()
        }
    }
    
    func didFinishChild(_ coordinator: Coordinator) {}
}

private extension RootUnspMainFlowCoordinator {
    func makeAuthorizedKeychain() -> KeychainStorageProtocol? {
        
        if let keychain = keychainFactory.make(),
           let token = try? keychain.string(forKey: StorageKeys.accessToken.rawValue),
           !token.isEmpty {
            
            return keychain
        }
        
        return nil
    }
}
