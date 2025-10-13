//
//  PhotosViewModel.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import UIKit
@preconcurrency import Combine
import KeychainStorageKit
import HelpersSharedUnsp

@MainActor
protocol PhotosViewModelProtocol {
    typealias State = PhotoDataServiceState
    var photoDataServiceState: PassthroughSubject<State, Never> { get }
    var imageSubject: PassthroughSubject<ImageItem, Never> { get }
    
    func fetchPhotosData()
    func fetchImages(from start: IndexPath, to end: IndexPath)
}

enum PhotoDataServiceState {
    case loading
    case loaded([PhotoItem])
    case failed(Error)
}

final class PhotosViewModel: PhotosViewModelProtocol {
    
    let photoDataServiceState: PassthroughSubject<State, Never>
    
    let imageSubject: PassthroughSubject<ImageItem, Never>
    
    private var photos: [Photo] = []
    
    private let photoDataRepo: PhotoDataRepositoryProtocol
    private let imagesRepo: ImagesRepositoryProtocol
    private let keychainStorage: KeychainStorageProtocol
    private let dateFormatter = DisplayDateFormatter()
    
    private var token = ""
    private var page = 0
    
    init(
        photoDataRepo: PhotoDataRepositoryProtocol,
        imagesRepo: ImagesRepositoryProtocol,
        keychainStorage: KeychainStorageProtocol
    ) {
        self.photoDataRepo = photoDataRepo
        self.imagesRepo = imagesRepo
        self.keychainStorage = keychainStorage
        photoDataServiceState = .init()
        imageSubject = .init()
    }
    
    func fetchPhotosData() {
        photoDataServiceState.send(.loading)
        page += 1
        
        Task {
            do {
                if token.isEmpty {
//                    token = try self.keychainStorage.string(forKey: StorageKeys.accessToken.rawValue) ?? ""
                    
#warning("remove line")
                    token = globalToken
                }
                
//                photos = try await photoDataRepo.fetch(
//                    page: page,
//                    size: 10,
//                    token: token
//                )
                
                photos = (0...9).map({ Photo(id: "", urls: .init(small: ""), likes: $0, likedByUser: false, createdAt: .now, description: "") })
                let photoItems = convert(photos)
                photoDataServiceState.send(.loaded(photoItems))
            } catch {
                photoDataServiceState.send(.failed(error))
            }
        }
    }
    
    func fetchImages(from start: IndexPath, to end: IndexPath) {
        guard photos.indices.contains(start.row) else { return }
        
//        let url = photos[start.row].urls.small
//        let count = photos.count
        Task {
            do {
//                let image = try await imagesRepo.fetchImage(with: url)
//                imageSubject.send(ImageItem(id: UUID(), index: index, image: image))
                print(start, end)
                let items = (start.row...end.row).map({ ImageItem(id: .init(), index: .init(row: $0, section: 0), image: UIImage(systemName: "cross")!)})
                
                for item in items {
                    self.imageSubject.send(item)
//                    try await Task.sleep(for: .seconds(0.3))
                }
            } catch {
                print(error)
            }
        }
    }
}

private extension PhotosViewModel {
    func convert(_ photos: [Photo]) -> [PhotoItem] {
        photos.map({
            PhotoItem(
                likes: $0.likes,
                likedByUser: $0.likedByUser,
                createdAt: dateFormatter.string(from: $0.createdAt),
                description: $0.description
            )
        })
    }
}
