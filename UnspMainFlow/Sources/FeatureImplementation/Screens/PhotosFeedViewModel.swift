//
//  PhotosFeedViewModel.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import Foundation
import Combine
import KeychainStorageKit
import HelpersSharedUnsp

@MainActor
protocol PhotosFeedViewModelProtocol {
    typealias State = PhotoDataServiceState
    var photoDataServiceState: PassthroughSubject<State, Error> { get }
    
    func fetchPhotosData()
}

enum PhotoDataServiceState {
    case loading
    case loaded([PhotoItem])
    case failed(Error)
}

final class PhotosFeedViewModel: PhotosFeedViewModelProtocol {
    
    let photoDataServiceState: PassthroughSubject<State, Error>
    
    private var photoItems: [PhotoItem] = []
    
    private let photoDataRepo: PhotoDataRepositoryProtocol
    private let keychainStorage: KeychainStorageProtocol
    private let dateFormatter = DisplayDateFormatter()
    
    private var token = ""
    private var page = 0
    
    init(
        photoDataRepo: PhotoDataRepositoryProtocol,
        keychainStorage: KeychainStorageProtocol
    ) {
        self.photoDataRepo = photoDataRepo
        self.keychainStorage = keychainStorage
        self.photoDataServiceState = .init()
    }
    
    func fetchPhotosData() {
        photoDataServiceState.send(.loading)
        page += 1
        
        Task {
            do {
                if token.isEmpty {
                    token = try self.keychainStorage.string(forKey: StorageKeys.accessToken.rawValue) ?? ""
        
        #warning("remove line")
                    token = globalToken
                }
        
                let photos = try await photoDataRepo.fetch(
                    page: page,
                    size: 10,
                    token: token
                )
                
                let photoItems = convert(photos)
                photoDataServiceState.send(.loaded(photoItems))
            } catch {
                photoDataServiceState.send(.failed(error))
            }
        }
    }
}

private extension PhotosFeedViewModel {
    func convert(_ photos: [Photo]) -> [PhotoItem] {
        photos.map({
            PhotoItem(
                id: $0.id,
                likes: $0.likes,
                likedByUser: $0.likedByUser,
                createdAt: dateFormatter.string(from: $0.createdAt),
                description: $0.description
            )
        })
    }
}
