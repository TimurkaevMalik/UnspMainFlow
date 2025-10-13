//
//  ImageCollectionController.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 12.10.2025.
//

import UIKit
import CoreKit

final class ImageCollectionController: UICollectionViewController {
    
    private let vm: PhotosViewModel
    private lazy var dataSource = makeDataSource()
    private lazy var snapShot = NSDiffableDataSourceSnapshot<Section, ImageItem>()
    
    init(
        vm: PhotosViewModel,
        layoutFactory: CollectionCompositionalLayoutFactory
    ) {
        self.vm = vm
        super.init(collectionViewLayout: layoutFactory.make())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollection()
        configureSnapshot()
        applySnapshot(items: [])
    }
}

private extension ImageCollectionController {
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, ImageItem> {
        
        UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collection, indexPath, item in
                
                guard let cell = collection.dequeueReusableCell(
                        withReuseIdentifier: ImageCollectionCell.identifier,
                        for: indexPath) as? ImageCollectionCell
                else {
                    return UICollectionViewCell()
                }

                cell.set(image: item.image)
                return cell
            }
        )
    }
    
    func applySnapshot(items: [ImageItem]) {
        snapShot.appendItems(items, toSection: .main)
        dataSource.apply(snapShot, animatingDifferences: true)
    }
    
    func configureSnapshot() {
        snapShot.appendSections([.main])
    }
    
    func configureCollection() {
        collectionView.backgroundColor = Palette.Asset.whitePrimary.uiColor
        collectionView.dataSource = dataSource
        collectionView.register(
            ImageCollectionCell.self,
            forCellWithReuseIdentifier: ImageCollectionCell.identifier
        )
    }

    enum Section: Int {
        case main
    }
}
