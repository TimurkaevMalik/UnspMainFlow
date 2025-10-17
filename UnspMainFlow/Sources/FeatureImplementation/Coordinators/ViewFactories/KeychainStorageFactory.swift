//
//  KeychainStorageFactory.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import Foundation
import CoreKit
import LoggingKit
import KeychainStorageKit
import HelpersSharedUnsp

final class KeychainStorageFactory {
    private let preferences: PreferencesProtocol
    
    init(preferences: PreferencesProtocol = UserDefaults.standard) {
        self.preferences = preferences
    }
    
    func make() -> KeychainStorageProtocol? {
        let logger = OSLogAdapter(
            subsystem: "com.yourcompany.unspauthorization",
            category: ""
        )
        
        let userID = preferences.retrieve(
            String.self,
            forKey: StorageKeys.currentUserID.rawValue
        )
        
        guard let userID else { return nil }
        
        return ValetStorage(
            id: userID,
            accessibility: .whenUnlockedThisDeviceOnly,
            logger: RootCompositeLogger(loggers: [logger])
        )
    }
}
