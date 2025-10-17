//
//  PhotoFeedControllerFactory.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit
import KeychainStorageKit

@MainActor
final class PhotoFeedControllerFactory {
    
    func makeWith(tokenStorage: TokenStorageProtocol) -> UIViewController {
        let requestFactory = AuthorizedRequestFactory()
        let networkHelper = DefaultNetworkServiceHelper()
        
        let photoDataService = PhotosDataService(
            requestFactory: requestFactory,
            helper: networkHelper
        )
        let imageService = ImageService()
        
        let photoDataRepo = PhotoDataRepository(
            photoDataService: photoDataService,
            tokenStorage: tokenStorage
        )
        
        let imagesRepo = ImagesRepository(imageService: imageService)
        
        let viewModel = PhotosViewModel(
            photoDataRepo: photoDataRepo,
            imagesRepo: imagesRepo
        )
        
        let layoutFactory = TripleSectionLayoutFactory()
        
        let imageCollectionController = ImageCollectionController(
            vm: viewModel,
            layoutFactory: layoutFactory
        )
        
        return PhotoFeedController(photoFeedCollectionController: imageCollectionController)
    }
}
