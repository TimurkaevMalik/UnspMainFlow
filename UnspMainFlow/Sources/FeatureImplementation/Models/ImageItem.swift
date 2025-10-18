//
//  ImageItem.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 14.10.2025.
//

import UIKit

///Model for Presentation layer
struct ImageItem: Hashable, Identifiable {
    var id: String
    var image: UIImage?
    
    init(id: String, image: UIImage? = nil) {
        self.id = id
        self.image = image
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        lhs.id == rhs.id
    }
}
