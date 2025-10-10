//
//  PhotoDataRepositories.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import Foundation

protocol PhotoDataRepositoryProtocol {
    func fetchWith(token: String) async throws -> [Photo]
}

final class PhotoDataRepository: PhotoDataRepositoryProtocol {
    
    #warning("Можно ли напрямую обращаться к форматтерам?")
    private let displayDateFormatter = DisplayDateFormatter()
    private let defaultDateFormatter = DefaultDateFormatter()
    
    private let photoDataService: PhotosDataServiceProtocol
    private var lastPage = 0
    
    init(photoDataService: PhotosDataServiceProtocol) {
        self.photoDataService = photoDataService
    }
    
    func fetchWith(token: String) async throws -> [Photo] {
        lastPage += 1
        let photosDTO = try await photoDataService.fetchPhotos(
            page: lastPage,
            size: 10,
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
        defaultDateFormatter.date(from: string)
    }
}
