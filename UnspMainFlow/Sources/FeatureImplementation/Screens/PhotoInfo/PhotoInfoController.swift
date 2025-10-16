//
//  PhotoInfoController.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 13.10.2025.
//

import UIKit
import CoreKit
import SnapKit
import Combine

final class PhotoInfoController: UIViewController {
    
    private let vm: PhotoLikeViewModelProtocol
    private var cancellable = Set<AnyCancellable>()

    private lazy var rootView = PhotoInfoView()
    
    init(vm: PhotoLikeViewModelProtocol) {
        self.vm = vm
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
        title = "Photo"
        rootView.setupUI()
        setupActions()
        bindViewModel()
    }
}

private extension PhotoInfoController {
    func bindViewModel() {
        vm.photoItemPublisher
            .receive(on: DispatchQueue.main)
            .sink { item in
                
                self.rootView.likeButton.isLiked = item.likedByUser
                self.rootView.dateLabel.text = item.createdAt
                self.rootView.descriptionTextView.text = item.description
                self.rootView.likesCountLabel.text = "\(item.likes)"
            }
            .store(in: &cancellable)
        
        vm.imagePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: rootView.imageView)
            .store(in: &cancellable)
    }
}

private extension PhotoInfoController {
    func setupActions() {
        rootView.likeButton.addAction(
            UIAction { [weak self] _ in
                guard let self else { return }
                rootView.likeButton.isLiked ? vm.unlike() : vm.like()
            },
            for: .touchUpInside
        )
    }
}
