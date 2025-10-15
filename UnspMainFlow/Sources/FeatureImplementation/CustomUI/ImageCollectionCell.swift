//
//  ImageCollectionCell.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 13.10.2025.
//

import UIKit
import CoreKit

final class ImageCollectionCell: UICollectionViewCell {
    
    static let identifier = "PhotoPostCollectionCell"
    
    private lazy var imageView = {
        let uiView = UIImageView()
        uiView.contentMode = .scaleAspectFill
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(image: UIImage) {
        imageView.image = image
    }
}

private extension ImageCollectionCell {
    func setupUI() {
        contentView.layer.cornerRadius = 6
        contentView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        imageView.backgroundColor = Palette.Asset.blackPrimary.uiColor
        imageView.snp.makeConstraints ({
            $0.edges.equalTo(contentView)
        })
    }
}
