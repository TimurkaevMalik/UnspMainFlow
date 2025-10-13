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
        uiView.backgroundColor = .red
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
        return uiView
    }()
    
    private lazy var likeButton = {
        let customView = LikeButton(isLiked: imageInfo.likedByUser)
        customView.translatesAutoresizingMaskIntoConstraints = false
        return customView
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
        setupUI()
        setupAction()
    }
}

private extension PhotoInfoController {
    func setupUI() {
        let buttonHeight = 42
        let buttonsHorizontalInset = 64
        let safeArea = view.safeAreaLayoutGuide
        
        title = "Photo"
        view.backgroundColor = Palette.Asset.whitePrimary.uiColor
        
        view.addSubview(imageView)
        view.addSubview(infoContainerView)
        view.addSubview(buttonsContainerView)
        view.addSubview(infoButton)
        view.addSubview(likeButton)
       
        buttonsContainerView.snp.makeConstraints({
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(buttonHeight + 24)
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
            $0.bottom.equalTo(safeArea).inset(buttonsContainerView.frame.height)
        })
        
        infoContainerView.backgroundColor = .green
        
        infoContainerView.snp.makeConstraints({
            $0.top.equalTo(buttonsContainerView)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(50)
        })
    }
    
    func setupAction() {
        let action = UIAction { [weak self] _ in
            self?.likeButton.isLiked.toggle()
        }
        likeButton.addAction(action, for: .touchUpInside)
    }
}
