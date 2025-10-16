//
//  TokenCacheProtocol.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 16.10.2025.
//

import Foundation
import KeychainStorageKit
import HelpersSharedUnsp

@MainActor
protocol TokenStorageProtocol {
    func getToken() throws -> String
    func clearToken()
}

final class TokenCache: TokenStorageProtocol {
    private let keychain: KeychainStorageProtocol
    private var cachedToken: String = ""

    init(keychain: KeychainStorageProtocol) {
        self.keychain = keychain
    }

    func getToken() throws -> String {
        if !cachedToken.isEmpty {
            return cachedToken
        }

        
        cachedToken = try keychain.string(forKey: StorageKeys.accessToken.rawValue) ?? ""
        
        #warning("Remove global token")
        cachedToken = globalToken

        return cachedToken
    }

    func clearToken() {
        cachedToken = ""
    }
}
