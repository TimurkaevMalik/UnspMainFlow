//
//  PhotoItem.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import UIKit

///Presentation layer
struct PhotoItem {
    let id: UUID
    let index: Int
    let likes: Int
    let likedByUser: Bool
    let createdAt: String
    let description: String
}
