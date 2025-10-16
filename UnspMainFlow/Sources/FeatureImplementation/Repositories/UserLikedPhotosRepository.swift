//
//  UserLikedPhotosRepository.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 16.10.2025.
//

import Foundation

@MainActor
protocol UserLikedPhotosRepositoryProtocol {
    func fetchPhotos(page: Int, size: Int, user: String) async throws -> [Photo]
}

final class UserLikedPhotosRepository: UserLikedPhotosRepositoryProtocol {
    
    private let dateFormatter = DefaultDateFormatter()
    private let photoDataService: UserLikedPhotosServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    
    init(
        photoDataService: UserLikedPhotosServiceProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.photoDataService = photoDataService
        self.tokenStorage = tokenStorage
    }
    
    func fetchPhotos(page: Int, size: Int, user: String) async throws -> [Photo] {
   
        let token = try tokenStorage.getToken()
        
        let photosDTO = try await photoDataService.fetchPhotos(
            page: page,
            size: size,
            user: user,
            token: token
        )
        
        return makePhotos(photosDTO)
    }
}

private extension UserLikedPhotosRepository {
    func makePhotos(_ photosDTO: [PhotoDTO]) -> [Photo] {
        return photosDTO.compactMap({
            
            guard let createdAt = date(from: $0.createdAt) else { return nil }
            
            return Photo(
                id: $0.id,
                urls: $0.urls,
                likes: $0.likes,
                likedByUser: $0.likedByUser,
                createdAt: createdAt,
                description: $0.description
            )
        })
    }
    
    func date(from string: String) -> Date? {
        dateFormatter.date(from: string)
    }
}
