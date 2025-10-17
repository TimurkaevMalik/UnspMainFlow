//
//  CollectionCompositionalLayoutFactory.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 13.10.2025.
//

import UIKit
import CoreKit

@MainActor
protocol CollectionCompositionalLayoutFactory {
    func make() -> UICollectionViewCompositionalLayout
}

final class TripleSectionLayoutFactory: CollectionCompositionalLayoutFactory {
    
    func make() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { section, _ in
            let inset = LayoutGrid.xxs
            
            let rightTopItem = NSCollectionLayoutItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(0.5)
                ))
            
            let rightBottomItem = NSCollectionLayoutItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(0.5)
                ))
            
            let leftItem = NSCollectionLayoutItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(0.4),
                    heightDimension: .fractionalHeight(1)
                ))
            
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(0.6),
                    heightDimension: .fractionalHeight(1)
                ),
                subitems: [rightTopItem, rightBottomItem]
            )
            
            verticalGroup.interItemSpacing = .fixed(inset)
            
            let mainGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1/3)
                ),
                subitems: [leftItem, verticalGroup]
            )
            
            mainGroup.interItemSpacing = .fixed(inset)
            
            let section = NSCollectionLayoutSection(group: mainGroup)
            section.interGroupSpacing = inset
            section.contentInsets = .init(top: inset, leading: inset, bottom: inset, trailing: inset)
            
            return section
        }
    }
}
