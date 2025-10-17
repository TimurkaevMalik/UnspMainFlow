//
//  PhotosFeedView.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 12.10.2025.
//

import UIKit
import SnapKit
import CoreKit

final class PhotoFeedView: UIView {
    
    private let photosCollectionView: UICollectionView
    
    init(photosCollectionView: UICollectionView) {
        self.photosCollectionView = photosCollectionView
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PhotoFeedView {
    func setupUI() {
        backgroundColor = Palette.Asset.whitePrimary.uiColor
        addSubview(photosCollectionView)
        photosCollectionView.showsVerticalScrollIndicator = false
        photosCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        photosCollectionView.snp.makeConstraints ({
            $0.edges.equalTo(safeAreaLayoutGuide)
        })
    }
}
