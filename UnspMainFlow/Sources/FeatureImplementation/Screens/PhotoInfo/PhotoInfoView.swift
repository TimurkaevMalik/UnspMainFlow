//
//  PhotoInfoView.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 16.10.2025.
//

import UIKit
import SnapKit
import CoreKit

final class PhotoInfoView: UIView {
    lazy var imageView = {
        let uiView = UIImageView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.contentMode = .scaleAspectFit
        return uiView
    }()
        
    lazy var likeButton = {
        let customView = LikeButton(isLiked: false)
        customView.translatesAutoresizingMaskIntoConstraints = false
        return customView
    }()
    
    lazy var likesCountLabel = {
        let uiView = UILabel()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    lazy var dateLabel = {
        let uiView = UILabel()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    lazy var descriptionTextView = {
        let uiView = UITextView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    private lazy var infoButton = {
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = Palette.Asset.blackPrimary.uiColor
        config.baseForegroundColor = Palette.Asset.whitePrimary.uiColor
        config.title = "Info"
        config.cornerStyle = .small
        config.contentInsets = .init(top: 0, leading: 32, bottom: 0, trailing: 32)
        let uiView = UIButton(configuration: config)
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    private lazy var buttonsContainerView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = Palette.Asset.whitePrimary.uiColor
        return uiView
    }()
    
    private lazy var infoContainerView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = Palette.Asset.whitePrimary.uiColor
        return uiView
    }()
    
    private var infoContainerState: InfoContainerState = .collapse
    private var infoContainerViewTopConstraint: Constraint?
    private lazy var infoContainerOffsetY: CGFloat = {
        bounds.maxY - safeAreaInsets.top
    }()
    
    func setupUI() {
        backgroundColor = Palette.Asset.whitePrimary.uiColor
        setupViewsHierarchy()
        setupSubViews()
        setupInfoContainerView()
    }
}

private extension PhotoInfoView {
    var infoButtonAction: UIAction {
        UIAction { [weak self] _ in
            self?.toggleInfoContainer()
        }
    }
    
    func toggleInfoContainer() {
        switch infoContainerState {
            
        case .expand:
            collapseInfoContainer()
        case .collapse:
            expandInfoContainer()
        }
    }
    
    func expandInfoContainer() {
        infoContainerViewTopConstraint?.update(offset: -infoContainerOffsetY)
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.infoContainerState = .expand
        }
    }
    
    func collapseInfoContainer() {
        infoContainerViewTopConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.5) {
            self.layoutIfNeeded()
        } completion: { _ in
            self.infoContainerState = .collapse
        }
    }
}

private extension PhotoInfoView {
    func setupViewsHierarchy() {
        addSubview(imageView)
        addSubview(infoContainerView)
        addSubview(dateLabel)
        addSubview(descriptionTextView)
        addSubview(buttonsContainerView)
        addSubview(infoButton)
        addSubview(likeButton)
        addSubview(likesCountLabel)
    }
    
    func setupSubViews() {
        let buttonHeight = 42
        let buttonsContainerViewHeight = buttonHeight + 24
        let buttonsHorizontalInset = 64
        
        buttonsContainerView.snp.makeConstraints({
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(buttonsContainerViewHeight)
        })
        
        infoButton.snp.makeConstraints({
            $0.height.equalTo(buttonHeight)
            $0.centerY.equalTo(buttonsContainerView)
            $0.left.equalTo(buttonsContainerView).inset(buttonsHorizontalInset)
        })
        
        likeButton.snp.makeConstraints({
            $0.size.equalTo(buttonHeight)
            $0.centerY.equalTo(buttonsContainerView)
            $0.right.equalTo(buttonsContainerView).inset(buttonsHorizontalInset)
        })
        
        imageView.snp.makeConstraints({
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.bottom.equalToSuperview().inset(buttonsContainerViewHeight)
        })
        
        likesCountLabel.snp.makeConstraints({
            $0.centerY.equalTo(likeButton.snp.centerY)
            $0.right.equalTo(likeButton.snp.right).offset(18)
        })
    }
    
    func setupInfoContainerView() {
        dateLabel.textColor = .white
        descriptionTextView.textColor = .white
        dateLabel.backgroundColor = .clear
        descriptionTextView.backgroundColor = .clear
        infoContainerView.backgroundColor = .black.withAlphaComponent(0.3)
        
        infoContainerView.snp.makeConstraints({
            infoContainerViewTopConstraint = $0.top.equalTo(snp.bottom).constraint
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(snp.height)
        })
        
        dateLabel.snp.makeConstraints({
            $0.horizontalEdges.top.equalTo(infoContainerView).inset(20)
        })
        
        descriptionTextView.snp.makeConstraints({
            $0.top.equalTo(dateLabel.snp.bottom).offset(20)
            $0.horizontalEdges.bottom.equalTo(infoContainerView)
        })
    }
    
    func setupActions() {
        infoButton.addAction(infoButtonAction, for: .touchUpInside)
    }
}

private extension PhotoInfoView {
    enum InfoContainerState {
        case expand
        case collapse
    }
}
