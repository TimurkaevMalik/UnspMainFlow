//
//  UICollectionView+ext.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 15.10.2025.
//

import UIKit

extension UICollectionView {
    func register(_ cell: AnyClass?, identifier: String) {
        self.register(cell, forCellWithReuseIdentifier: identifier)
    }
}

@MainActor
extension UICollectionView.CellRegistration {
    var cellProvider: (UICollectionView, IndexPath, Item) -> Cell {
        return { collection, indexPath, item in
            collection.dequeueConfiguredReusableCell(
                using: self,
                for: indexPath,
                item: item
            )
        }
    }
}
