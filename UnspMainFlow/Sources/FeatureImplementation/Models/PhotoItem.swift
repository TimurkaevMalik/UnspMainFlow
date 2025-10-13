//
//  PhotoItem.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import UIKit

///Presentation layer
struct PhotoItem {
    let likes: Int
    let likedByUser: Bool
    let createdAt: String
    let description: String
}

struct ImageItem: Hashable {
    let id: UUID
    let index: IndexPath
    let image: UIImage
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
