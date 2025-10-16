//
//  PhotoDTO.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import Foundation
import NetworkKit

///Models for Data layer
struct PhotoDTO: Decodable {
    let id: String
    let urls: PhotoURLs
    let likes: Int
    let likedByUser: Bool
    let createdAt: String
    @DefaultEmptyString var description: String
    
    enum CodingKeys: String, CodingKey {
        case id, likes, description, urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

struct LikeResponseDTO: Decodable {
    let photo: PhotoDTO
}
