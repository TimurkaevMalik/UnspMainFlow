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
import LoggingKit

public final class RootUnspMainFlowCoordinator: FlowCoordinator {
    
    public var child: Coordinator?
    public weak var finishDelegate: CoordinatorFinishDelegate?
    
    #warning("Можно ли передавать window в координатор для tabBar?")
    private let window: UIWindow
    
    public init(
        finishDelegate: CoordinatorFinishDelegate? = nil,
        window: UIWindow
    ) {
        self.finishDelegate = finishDelegate
        self.window = window
    }
    
    public func start() {
        
        if let keychain = makeAuthorizedKeychain() {
            let tabBarCoordinator = TabBarCoordinator(
                finishDelegate: self,
                keychain: keychain
            )
            
            child = tabBarCoordinator
            child?.start()
            window.rootViewController = tabBarCoordinator.tabBarController
            window.makeKeyAndVisible()
            
        } else {
            let logger = OSLogAdapter(subsystem: "", category: "")
            let message = "UnspMainFlow has been terminated due to lack of authorization"
            
            logger.record(message, level: .notice)
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
