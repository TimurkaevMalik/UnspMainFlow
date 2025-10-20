//
//  PhotoLikeRepository.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 16.10.2025.
//

import Foundation

@MainActor
protocol PhotoLikeRepositoryProtocol {
    func like(photoID: String) async throws -> Photo
    func unlike(photoID: String) async throws -> Photo
}

final class PhotoLikeRepository: PhotoLikeRepositoryProtocol {
    
    private let dateFormatter = DefaultDateFormatter()
    private let likeService: PhotoLikeServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    private var token = ""
    
    init(
        likeService: PhotoLikeServiceProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.likeService = likeService
        self.tokenStorage = tokenStorage
    }
    
    func like(photoID: String) async throws -> Photo {
        let token = try tokenStorage.getToken()
        
        let dto = try await likeService.like(photoID: photoID, token: token)
        return try makePhoto(dto)
    }
    
    func unlike(photoID: String) async throws -> Photo {
        let token = try tokenStorage.getToken()
        
        let dto = try await likeService.unlike(photoID: photoID, token: token)
        return try makePhoto(dto)
    }
}

private extension PhotoLikeRepository {
    func makePhoto(_ photoDTO: PhotoDTO) throws -> Photo {
        
        guard let createdAt = date(from: photoDTO.createdAt) else {
            throw RepositoryError.invalidDate(photoDTO.createdAt)
        }
        
        return Photo(
            id: photoDTO.id,
            urls: photoDTO.urls,
            likes: photoDTO.likes,
            likedByUser: photoDTO.likedByUser,
            createdAt: createdAt,
            description: photoDTO.description
        )
    }
    
    func date(from string: String) -> Date? {
        dateFormatter.date(from: string)
    }
}

extension PhotoLikeRepository {
    enum RepositoryError: Error {
        case invalidDate(String)
    }
}
