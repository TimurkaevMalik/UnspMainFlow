//
//  DiffableCollectionControllerProtocol.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 18.10.2025.
//

import UIKit

protocol DiffableCollectionControllerProtocol {
    associatedtype Cell: UICollectionViewCell
    associatedtype Section: Hashable
    associatedtype ItemIdentifier: Hashable

    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, ItemIdentifier>
    typealias CellRegistration = UICollectionView.CellRegistration<Cell, ItemIdentifier>
    typealias DataSource = UICollectionViewDiffableDataSource<Section, ItemIdentifier>
}
