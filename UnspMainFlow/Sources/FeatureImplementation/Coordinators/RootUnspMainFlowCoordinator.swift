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
    
    private let window: UIWindow
    
    public init(
        finishDelegate: CoordinatorFinishDelegate? = nil,
        window: UIWindow
    ) {
        self.finishDelegate = finishDelegate
        self.window = window
    }
    
    public func start() {
#warning("remove ValetStorage")
        let keychain = ValetStorage(id: " ", accessibility: .whenUnlockedThisDeviceOnly, logger: nil)
        
#warning("Set makeAuthorizedKeychain()")
        if let keychain  {
            let tabBarCoordinator = TabBarCoordinator(
                finishDelegate: self,
                keychain: keychain
            )
            
            child = tabBarCoordinator
            child?.start()
            window.rootViewController = tabBarCoordinator.tabBarController
            window.makeKeyAndVisible()
            
        } else {
            print("finish")
            finish()
        }
    }
    
    public func didFinishChild(_ coordinator: Coordinator) {}
}

private extension RootUnspMainFlowCoordinator {
    func makeAuthorizedKeychain() -> KeychainStorageProtocol? {
        
        if let keychain =  KeychainStorageFactory().make(),
           let token = try? keychain.string(forKey: StorageKeys.accessToken.rawValue),
           !token.isEmpty {
            
            return keychain
        }
        
        return nil
    }
}
