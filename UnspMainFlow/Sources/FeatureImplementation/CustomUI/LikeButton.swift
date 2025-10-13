//
//  LikeButton.swift
//  
//
//  Created by Malik Timurkaev on 14.10.2025.
//

import UIKit
import CoreKit
import SnapKit

final class LikeButton: UIButton {
    
    var isLiked: Bool {
        didSet {
            changeState()
        }
    }
    
    private lazy var likeImageView = {
        let uiView = UIImageView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    init(isLiked: Bool) {
        self.isLiked = isLiked
        super.init(frame: .zero)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension LikeButton {
    func changeState() {
        let imageName = isLiked ? "heart.fill" : "heart"
        likeImageView.image = UIImage(systemName: imageName)
    }
}

private extension LikeButton {
    func setupUI() {
        addSubview(likeImageView)
        likeImageView.tintColor = .systemRed
        likeImageView.contentMode = .scaleAspectFit
        
        likeImageView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        
        changeState()
    }
}
