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

public final class RootUnspMainFlowCoordinator: FlowCoordinator {
    
    public var child: Coordinator?
    public weak var finishDelegate: CoordinatorFinishDelegate?
    
    private let navigation: UINavigationController
    private let keychainFactory = KeychainStorageFactory()
    
    public init(
        finishDelegate: CoordinatorFinishDelegate? = nil,
        navigation: UINavigationController,
    ) {
        self.finishDelegate = finishDelegate
        self.navigation = navigation
    }
    
    public func start() {
#warning("remove ValetStorage")
        let keychain = ValetStorage(id: " ", accessibility: .whenUnlockedThisDeviceOnly, logger: nil)
        
        if let keychain  {
            child = TabBarCoordinator(
                finishDelegate: self,
                navigation: navigation,
                keychain: keychain
            )
            
            child?.start()
        } else {
            print("finish")
            finish()
        }
    }
    
    public func didFinishChild(_ coordinator: Coordinator) {}
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
