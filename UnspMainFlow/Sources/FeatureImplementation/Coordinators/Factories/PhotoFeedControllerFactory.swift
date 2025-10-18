//
//  PhotoFeedControllerFactory.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit

@MainActor
final class PhotoFeedControllerFactory {
    
    func makeWith(
        tokenStorage: TokenStorageProtocol,
        output: ImageCollectionControllerOutput? = nil
    ) -> UIViewController {
        let requestFactory = AuthorizedRequestFactory()
        let networkHelper = DefaultNetworkServiceHelper()
        
        let photoDataService = PhotosDataService(
            requestFactory: requestFactory,
            helper: networkHelper
        )
        let photoSearchService = PhotosSearchService(
            requestFactory: requestFactory,
            helper: networkHelper
        )
        
        let photoDataRepo = PhotoDataRepository(
            photoDataService: photoDataService,
            tokenStorage: tokenStorage
        )
        let photoSearchRepo = PhotosSearchRepository(
            photosDataService: photoSearchService,
            tokenStorage: tokenStorage
        )
        
        let imageService = ImageService()
        let imagesRepo = ImagesRepository(imageService: imageService)
        
        let viewModel = PhotosSearchViewModel(
            photoDataRepo: photoDataRepo,
            photoSearchRepo: photoSearchRepo,
            imagesRepo: imagesRepo
        )
        
        let layoutFactory = TripleSectionLayoutFactory()
        
        let imageCollectionController = SearchImageCollectionController(
            output: output,
            vm: viewModel,
            layoutFactory: layoutFactory
        )
        imageCollectionController.title = "Remove title"
        
        #warning("remove")
        return PhotoFeedController(photoFeedCollectionController: imageCollectionController)
//        return imageCollectionController
    }
}
