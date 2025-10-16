//
//  PhotoFeedController.swift
//  AppModule
//
//  Created by Malik Timurkaev on 04.10.2025.
//

import UIKit
import CoreKit
import Combine

final class PhotoFeedController: UIViewController {
    
    private let photoFeedCollectionController: ImageCollectionController
    
    private lazy var rootView = {
        PhotoFeedView(photosCollectionView: photoFeedCollectionController.collectionView)
    }()
    
    init(photoFeedCollectionController: ImageCollectionController) {
        self.photoFeedCollectionController = photoFeedCollectionController
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(photoFeedCollectionController)
        photoFeedCollectionController.didMove(toParent: self)
        setUI()
    }
}

private extension PhotoFeedController {
    func setUI() {
        view.backgroundColor = Palette.Asset.whitePrimary.uiColor
        title = "Photo Feed"
    }
}
