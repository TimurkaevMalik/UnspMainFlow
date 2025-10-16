//
//  PhotoDataRepository.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import Foundation

@MainActor
protocol PhotoDataRepositoryProtocol {
    func fetch(page: Int, size: Int) async throws -> [Photo]
}

final class PhotoDataRepository: PhotoDataRepositoryProtocol {
    
    #warning("Можно ли напрямую обращаться к форматтерам, а не передавать через инициализатор? Ведь мы и так можем тестировать и нам подменять не нужно.")
    private let dateFormatter = DefaultDateFormatter()
    private let photoDataService: PhotosDataServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    
    init(
        photoDataService: PhotosDataServiceProtocol,
        tokenStorage: TokenStorageProtocol
    ) {
        self.photoDataService = photoDataService
        self.tokenStorage = tokenStorage
    }
    
    func fetch(page: Int, size: Int) async throws -> [Photo] {
        let token = try tokenStorage.getToken()
        
        let photosDTO = try await photoDataService.fetchPhotos(
            page: page,
            size: size,
            token: token
        )
        
        return convert(photosDTO: photosDTO)
    }
}

private extension PhotoDataRepository {
    func convert(photosDTO: [PhotoDTO]) -> [Photo] {
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
