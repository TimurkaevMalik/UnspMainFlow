//
//  PhotosSearchRepository.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 18.10.2025.
//

import Foundation

@MainActor
protocol PhotosSearchRepositoryProtocol {
    func fetch(page: Int, size: Int, query: String) async throws -> [Photo]
}

final class PhotosSearchRepository: PhotosSearchRepositoryProtocol {
    
    private let dateFormatter = DefaultDateFormatter()
    private let photosDataService: PhotosSearchServiceProtocol
    private var tokenStorage: TokenStorageProtocol
    
    init(
        photosDataService: PhotosSearchServiceProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.photosDataService = photosDataService
        self.tokenStorage = tokenStorage
    }
    
    func fetch(page: Int, size: Int, query: String) async throws -> [Photo] {
        
        let token = try tokenStorage.getToken()
        
        let photosDTO = try await photosDataService.searchPhotos(
            page: page,
            size: size,
            query: query,
            token: token
        )
        
        return makePhotos(photosDTO)
    }
}

private extension PhotosSearchRepository {
    func makePhotos(_ photosDTO: [PhotoDTO]) -> [Photo] {
        return photosDTO.compactMap({
            
            guard let createdAt = date(from: $0.createdAt) else { return nil }
            
            return Photo(
                id: $0.id,
                urls: $0.urls,
                likes: $0.likes,
                likedByUser: $0.likedByUser,
                createdAt: createdAt,
                description: $0.description ?? ""
            )
        })
    }
    
    func date(from string: String) -> Date? {
        dateFormatter.date(from: string)
    }
}
