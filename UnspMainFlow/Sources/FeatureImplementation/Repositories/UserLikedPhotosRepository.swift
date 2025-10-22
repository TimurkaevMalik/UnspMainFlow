//
//  UserLikedPhotosRepository.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 16.10.2025.
//

import Foundation
import CoreKit
import HelpersSharedUnsp

final class UserLikedPhotosRepository: PhotoDataRepositoryProtocol {
    
    private let dateFormatter = DefaultDateFormatter()
    private let photoDataService: UserLikedPhotosServiceProtocol
    private let tokenStorage: TokenStorageProtocol
    private let preferences: PreferencesProtocol
    
    init(
        photoDataService: UserLikedPhotosServiceProtocol,
        tokenStorage: TokenStorageProtocol,
        preferences: PreferencesProtocol
    ) {
        self.photoDataService = photoDataService
        self.tokenStorage = tokenStorage
        self.preferences = preferences
    }
    
    func fetch(page: Int, size: Int) async throws -> [Photo] {
        
        guard let user = preferences.retrieve(String.self, forKey: StorageKeys.currentUserID.rawValue) else {
            throw PreferencesError.didNotFindUserID
        }
        
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
                description: $0.description ?? ""
            )
        })
    }
    
    func date(from string: String) -> Date? {
        dateFormatter.date(from: string)
    }
}

extension UserLikedPhotosRepository {
    enum PreferencesError: Error {
        case didNotFindUserID
    }
}
