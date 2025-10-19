//
//  PhotoSearchFeedControllerFactory.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 17.10.2025.
//

import UIKit

@MainActor
final class PhotoSearchFeedControllerFactory {
    
    func makeWith(
        tokenStorage: TokenStorageProtocol,
        output: ImageCollectionOutput? = nil
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
        let imagesRepo = ImagesRepository(
            imageService: imageService
        )
        
        let viewModel = PhotosSearchViewModel(
            photoDataRepo: photoDataRepo,
            photoSearchRepo: photoSearchRepo,
            imagesRepo: imagesRepo
        )
        
        let layoutFactory = TripleSectionLayoutFactory()
        
        let searchFeedView = PhotoSearchFeedView(
            output: output,
            vm: viewModel,
            layoutFactory: layoutFactory
        )
        return PhotoSearchFeedController(rootView: searchFeedView)
    }
}
