//
//  PhotoInfoController.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 13.10.2025.
//

import UIKit
import CoreKit
import SnapKit

final class PhotoInfoController: UIViewController {
    
    private lazy var imageView = {
        let uiView = UIImageView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.contentMode = .scaleAspectFit
        return uiView
    }()
    
    private lazy var infoButton = {
        var config = UIButton.Configuration.plain()
        config.background.backgroundColor = Palette.Asset.blackPrimary.uiColor
        config.title = "Info"
        config.cornerStyle = .small
        config.contentInsets = .init(top: 0, leading: 32, bottom: 0, trailing: 32)
        let uiView = UIButton(configuration: config)
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.addAction(infoButtonAction, for: .touchUpInside)
        return uiView
    }()
    
    private lazy var likeButton = {
        let customView = LikeButton(isLiked: imageInfo.likedByUser)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.addAction(likeButtonAction, for: .touchUpInside)
        return customView
    }()
    
    private lazy var buttonsContainerView = {
        let uiView = UIView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        uiView.backgroundColor = Palette.Asset.whitePrimary.uiColor
        return uiView
    }()
    
    private lazy var likesCountLabel = {
        let uiView = UILabel()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    private lazy var dateLabel = {
        let uiView = UILabel()
        uiView.translatesAutoresizingMaskIntoConstraints = false
        return uiView
    }()
    
    private lazy var descriptionTextView = {
        let uiView = UITextView()
        uiView.translatesAutoresizingMaskIntoConstraints = false
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
    private lazy var infoContainerOffset: CGPoint = {
        let x = view.bounds.maxX
        let y = view.bounds.maxY - view.safeAreaInsets.top
        return CGPoint(x: x, y: y)
    }()
    
    private let imageInfo: PhotoItem
    
    init(image: UIImage, info: PhotoItem) {
        imageInfo = info
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewsHierarchy()
        setupUI()
        setupInfoContainerView()
    }
}

private extension PhotoInfoController {
    func toggleInfoContainer() {
        switch infoContainerState {
            
        case .expand:
            collapseInfoContainer()
        case .collapse:
            expandInfoContainer()
        }
    }
    
    func expandInfoContainer() {
        infoContainerViewTopConstraint?.update(offset: -infoContainerOffset.y)
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.infoContainerState = .expand
        }
    }
    
    func collapseInfoContainer() {
        UIView.animate(withDuration: 0.5) {
            self.infoContainerViewTopConstraint?.update(offset: 0)
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.infoContainerState = .collapse
        }
    }
}

private extension PhotoInfoController {
    var infoButtonAction: UIAction {
        UIAction { [weak self] _ in
            self?.toggleInfoContainer()
        }
    }
    
    var likeButtonAction: UIAction {
        UIAction { [weak self] _ in
            self?.likeButton.isLiked.toggle()
        }
    }
}

private extension PhotoInfoController {
    enum InfoContainerState {
        case expand
        case collapse
    }
}

private extension PhotoInfoController {
    func setupViewsHierarchy() {
        view.addSubview(imageView)
        view.addSubview(infoContainerView)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
        view.addSubview(buttonsContainerView)
        view.addSubview(infoButton)
        view.addSubview(likeButton)
        view.addSubview(likesCountLabel)
    }
    
    func setupUI() {
        let buttonHeight = 42
        let buttonsContainerViewHeight = buttonHeight + 24
        let buttonsHorizontalInset = 64
        let safeArea = view.safeAreaLayoutGuide
        
        title = "Photo"
        likesCountLabel.text = "\(imageInfo.likes)"
        view.backgroundColor = Palette.Asset.whitePrimary.uiColor
        
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
            $0.top.equalTo(safeArea)
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
        dateLabel.text = imageInfo.createdAt
        descriptionTextView.text = imageInfo.description
        
        infoContainerView.snp.makeConstraints({
            infoContainerViewTopConstraint = $0.top.equalTo(view.snp.bottom).constraint
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(view.snp.height)
        })
        
        dateLabel.snp.makeConstraints({
            $0.horizontalEdges.top.equalTo(infoContainerView).inset(20)
        })
        
        descriptionTextView.snp.makeConstraints({
            $0.top.equalTo(dateLabel.snp.bottom).offset(20)
            $0.horizontalEdges.bottom.equalTo(infoContainerView)
        })
    }
}
