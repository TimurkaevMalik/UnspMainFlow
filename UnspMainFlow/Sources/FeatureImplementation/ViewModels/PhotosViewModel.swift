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
    
    var photosState: PassthroughSubject<State, Never> { get }
    var imagePublisher: PassthroughSubject<ImageItem, Never> { get }
    
    func fetchPhotosData()
    func fetchImages(for indexes: [Int])
    
    func imageItem(at index: Int) -> ImageItem
    func photoItem(at index: Int) -> PhotoItem
}

enum PhotoDataServiceState {
    case loading
    case loaded([PhotoItem])
    case failed(Error)
}

final class PhotosViewModel: PhotosViewModelProtocol {
    
    let photosState: PassthroughSubject<State, Never>
    let imagePublisher: PassthroughSubject<ImageItem, Never>
    
    private var photoEntries: [(data: Photo, item: ImageItem)] = []
    private var activeTasks: [Int: Task<(), Never>] = [:]
    private var currentPhotosPage = 0
    private var accessToken = ""
    
    private let photoDataRepo: PhotoDataRepositoryProtocol
    private let imagesRepo: ImagesRepositoryProtocol
    private let keychainStorage: KeychainStorageProtocol
    private let dateFormatter = DisplayDateFormatter()
    
    init(
        photoDataRepo: PhotoDataRepositoryProtocol,
        imagesRepo: ImagesRepositoryProtocol,
        keychainStorage: KeychainStorageProtocol
    ) {
        self.photoDataRepo = photoDataRepo
        self.imagesRepo = imagesRepo
        self.keychainStorage = keychainStorage
        photosState = .init()
        imagePublisher = .init()
    }
    
    func fetchPhotosData() {
        updatePhotosState(.loading)
        currentPhotosPage += 1
        
        Task {
            do {
                if accessToken.isEmpty {
                    accessToken = try self.keychainStorage.string(forKey: StorageKeys.accessToken.rawValue) ?? ""
                    
#warning("remove line")
                    accessToken = globalToken
                }
                
                var newPhotos = try await photoDataRepo.fetch(
                    page: currentPhotosPage,
                    size: 20,
                    token: accessToken
                )
                ///На стороне Unsplash баг с дупликатами
                ///Использую костыль ниже
                newPhotos.removeLast(3)
                
                let photoItems: [PhotoItem] = makePhotoItems(newPhotos)
                
                let data: [(data: Photo, item: ImageItem)] = zip(newPhotos, photoItems).map({
                    ($0, ImageItem(id: $1.id, index: $1.index))
                })
                
                photoEntries.append(contentsOf: data)
                updatePhotosState(.loaded(photoItems))
            } catch {
                updatePhotosState(.failed(error))
            }
        }
    }
    
    func fetchImages(for indexes: [Int]) {
        indexes.forEach({ fetchImage(at: $0) })
    }
    
    func imageItem(at index: Int) -> ImageItem {
        photoEntries[index].item
    }
    
    func photoItem(at index: Int) -> PhotoItem {
        let photoData = photoEntries[index]
        
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
    func fetchImage(at index: Int) {
        guard activeTasks[index] == nil,
              photoEntries[index].item.image == nil,
              photoEntries.count > index
        else { return }
        
        let url = photoEntries[index].data.urls.small
        
        let task = Task {
            do {
                let image = try await imagesRepo.fetchImage(with: url)
                photoEntries[index].item.image = image
                imagePublisher.send(photoEntries[index].item)
                activeTasks.removeValue(forKey: index)
            } catch {
                print(error)
            }
        }
        
        activeTasks.updateValue(task, forKey: index)
    }
    
    func makePhotoItems(_ photos: [Photo]) -> [PhotoItem] {
        photos.enumerated().map({ index, element in
            PhotoItem(
                id: element.id,
                index: index + self.photoEntries.count,
                likes: element.likes,
                likedByUser: element.likedByUser,
                createdAt: dateFormatter.string(from: element.createdAt),
                description: element.description
            )
        })
    }
    
    func updatePhotosState(_ state: State) {
        photosState.send(state)
    }
}
