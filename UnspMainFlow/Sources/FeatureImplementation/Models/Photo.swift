//
//  Photo.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import Foundation

///Model for Domain layer
struct Photo: Sendable {
    let id: String
    let urls: PhotoURLs
    let likes: Int
    let likedByUser: Bool
    let createdAt: Date
    let description: String
}
