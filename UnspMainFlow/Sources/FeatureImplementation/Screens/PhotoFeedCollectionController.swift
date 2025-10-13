//
//  ImageCollectionController.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 12.10.2025.
//

import UIKit
import CoreKit

final class ImageCollectionController: UICollectionViewController {
    
    private let vm: PhotoFeedViewModel
    #warning("Remove cellID")
    private let cellID = "CELLID"
    
    init(
        vm: PhotoFeedViewModel,
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
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: cellID
        )
    }
}

extension ImageCollectionController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellID,
            for: indexPath
        )
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        cell.backgroundColor = .systemBlue
        return cell
    }
}

