//
//  PhotoFeedViewController.swift
//  AppModule
//
//  Created by Malik Timurkaev on 04.10.2025.
//

import UIKit
import Combine

final class PhotoFeedViewController: UIViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    private let vm: PhotosViewModel
    
    private let photoFeedCollectionController: ImageCollectionController
    
    private lazy var rootView = {
        PhotoFeedView(photosCollectionView: photoFeedCollectionController.collectionView)
    }()
    
    init(
        vm: PhotosViewModel,
        photoFeedCollectionController: ImageCollectionController
    ) {
        self.vm = vm
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
        view.backgroundColor = .systemTeal
        
        addChild(photoFeedCollectionController)
        photoFeedCollectionController.didMove(toParent: self)
        
        bindVM()
    }
}

private extension PhotoFeedViewController {
    func bindVM() {
        vm.photoDataServiceState
            .receive(on: DispatchQueue.main)
            .sink { state in
                switch state {
                    
                case .loading:
                    print("Loading")
                case .loaded(let items):
                    print(items)
                case .failed(let error):
                    print("state", error)
                }
            }
            .store(in: &cancellables)
    }
}
