//
//  ProfileControllerFactory.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit

@MainActor
final class ProfileControllerFactory {
    
    func makeWith(
        tokenStorage: TokenStorageProtocol,
        output: ImageCollectionControllerOutput? = nil
    ) -> UIViewController {
        let requestFactory = AuthorizedRequestFactory()
        let networkHelper = DefaultNetworkServiceHelper()
        
        let likedPhotosService = UserLikedPhotosService(
            requestFactory: requestFactory,
            helper: networkHelper
        )
        let likedPhotoRepository = UserLikedPhotosRepository(
            photoDataService: likedPhotosService,
            tokenStorage: tokenStorage
        )
        
        let imageService = ImageService()
        let imagesRepo = ImagesRepository(imageService: imageService)
        
        let viewModel = PhotosViewModel(
            photoDataRepo: likedPhotoRepository,
            imagesRepo: imagesRepo
        )
        
        let layoutFactory = TripleSectionLayoutFactory()
        
        let imageCollectionController = ImageCollectionController(
            output: output,
            vm: viewModel,
            layoutFactory: layoutFactory
        )
        
        return PhotoFeedController(photoFeedCollectionController: imageCollectionController)
    }
}
