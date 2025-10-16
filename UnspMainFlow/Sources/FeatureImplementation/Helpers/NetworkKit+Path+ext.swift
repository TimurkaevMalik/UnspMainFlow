//
//  NetworkKit+Path+ext.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 06.10.2025.
//

import NetworkKit


extension Path {
    static let photos: Path = .segment("photos")
    static let like: Path = .segment("like")
    
    static func id(_ value: String) -> Path {
        Path.segment(value)
    }
}
