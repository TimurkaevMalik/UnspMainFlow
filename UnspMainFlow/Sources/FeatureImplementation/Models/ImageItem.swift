//
//  ImageItem.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 14.10.2025.
//

import Foundation
import UIKit

///Model for Presentation layer
struct ImageItem: Hashable, Identifiable {
    var id: String
    let index: Int
    var image: UIImage?
    
    init(
        id: String,
        index: Int,
        image: UIImage? = nil
    ) {
        self.id = id
        self.index = index
        self.image = image
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        lhs.id == rhs.id
    }
}
