//
//  NetworkKit+Path+ext.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 06.10.2025.
//

import NetworkKit


extension Path {
    static let photos: Path = .segment("photos")
    static let users: Path = .segment("users")
    static let likes: Path = .segment("likes")
    static let like: Path = .segment("like")
    static let search: Path = .segment("search")
    
    static func id(_ value: String) -> Path {
        .segment(value)
    }
    
    static func username(_ value: String) -> Path {
        .segment(value)
    }
}
