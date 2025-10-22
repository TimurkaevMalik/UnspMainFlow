//
//  PhotoDTO.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import Foundation
import NetworkKit

///Models for Data layer
struct PhotoDTO: Decodable, Sendable {
    let id: String
    let urls: PhotoURLs
    let likes: Int
    let likedByUser: Bool
    let createdAt: String
    var description: String?
    
    enum CodingKeys: String, CodingKey {
        case id, likes, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

///Wrapper for liked/unliked photo response
struct LikeResponseDTO: Decodable {
    let photo: PhotoDTO
}

///Wrapper for searched photos response
struct SearchedPhotosDTO: Decodable {
    let results: [PhotoDTO]
}
