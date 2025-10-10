//
//  PhotoDTO 2.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//


struct PhotoDTO: Decodable {
    let id: String
    let likes: Int
    let likedByUser: Bool
    let urls: PhotoURLs
    @DefaultEmptyString var description: String
    
    enum CodingKeys: String, CodingKey {
        case id, likes, description, urls
        case likedByUser = "liked_by_user"
    }
}

struct PhotoURLs: Decodable {
    let small: String
}
