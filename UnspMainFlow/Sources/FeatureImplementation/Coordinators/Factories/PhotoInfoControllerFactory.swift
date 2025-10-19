//
//  PhotoInfoControllerFactory.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit
import NetworkKit

@MainActor
final class PhotoInfoControllerFactory {
    func makeWith(
        tokenStorage: TokenStorageProtocol,
        photoItem: PhotoItem,
        image: UIImage
    ) -> UIViewController {
        
        let requestFactory = AuthorizedRequestFactory()
        let networkHelper = DefaultNetworkServiceHelper()
        
        let likeService = PhotoLikeService(
            requestFactory: requestFactory,
            helper: networkHelper
        )
        let likeRepository = PhotoLikeRepository(
            likeService: likeService,
            tokenStorage: tokenStorage
        )
        let viewModel = PhotoLikeViewModel(
            likeRepo: likeRepository,
            photoItem: photoItem,
            image: image
        )
        
        return PhotoInfoController(vm: viewModel)
    }
}
