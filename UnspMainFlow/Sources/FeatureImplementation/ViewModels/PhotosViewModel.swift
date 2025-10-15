//
//  PhotosViewModel.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import UIKit
import Combine
import KeychainStorageKit
import HelpersSharedUnsp

@MainActor
protocol PhotosViewModelProtocol {
    typealias State = PhotoDataServiceState
    var photoDataServiceState: PassthroughSubject<State, Never> { get }
    var imageSubject: PassthroughSubject<ImageItem, Never> { get }

    func fetchPhotosData()
    func fetchImagesFromPhotoData(indexes: [Int])
    func getImage(index: Int) -> UIImage?
    func getPhotoItem(index: Int) -> PhotoItem
}

enum PhotoDataServiceState {
    case loading
    case loaded([PhotoItem])
    case failed(Error)
}

final class PhotosViewModel: PhotosViewModelProtocol {
    
    let photoDataServiceState: PassthroughSubject<State, Never>
    let imageSubject: PassthroughSubject<ImageItem, Never>
    
    private var photos: [(data: Photo, item: ImageItem)] = []
    
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
                    token = try self.keychainStorage.string(forKey: StorageKeys.accessToken.rawValue) ?? ""
                    
#warning("remove line")
                    token = globalToken
                }
                
                let newPhotos = try await photoDataRepo.fetch(
                    page: page,
                    size: 20,
                    token: token
                )
                
                let photoItems: [PhotoItem] = convert(newPhotos)
                
                let data: [(data: Photo, item: ImageItem)] = zip(newPhotos, photoItems).map({
                    ($0, ImageItem(id: $1.id, index: $1.index))
                })
                
                photos.append(contentsOf: data)
                photoDataServiceState.send(.loaded(photoItems))
            } catch {
                photoDataServiceState.send(.failed(error))
            }
        }
    }
    
    func fetchImagesFromPhotoData(indexes: [Int]) {
        indexes.forEach({ fetchImageFromPhotoData(index: $0) })
    }
    
    func fetchImageFromPhotoData(index: Int) {
        guard photos.count > index else { return }
        let url = photos[index].data.urls.small
        
        Task {
            do {
                let image = try await imagesRepo.fetchImage(with: url)
                photos[index].item.image = image
                imageSubject.send(photos[index].item)
                
            } catch {
                print("fetchImage", error)
            }
        }
    }
    
    func getImage(index: Int) -> UIImage? {
        photos[index].item.image
    }
    
    func getPhotoItem(index: Int) -> PhotoItem {
        let photoData = photos[index]
        
        return PhotoItem(id: photoData.item.id,
                         index: index,
                         likes: photoData.data.likes,
                         likedByUser: photoData.data.likedByUser,
                         createdAt: dateFormatter.string(from: photoData.data.createdAt),
                         description: photoData.data.description
        )
    }
}

private extension PhotosViewModel {
    func convert(_ photos: [Photo]) -> [PhotoItem] {
        photos.enumerated().map({ index, element in
            PhotoItem(
                id: element.id,
                index: index + self.photos.count,
                likes: element.likes,
                likedByUser: element.likedByUser,
                createdAt: dateFormatter.string(from: element.createdAt),
                description: element.description
            )
        })
    }
}
