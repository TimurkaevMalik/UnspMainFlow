//
//  PhotosViewModel.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import Foundation
import Combine
import NetworkKit

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
    
    // MARK: - Properties
    let photosState: PassthroughSubject<State, Never> = .init()
    let imagePublisher: PassthroughSubject<ImageItem, Never> = .init()
    
    private var photoEntries: [(data: Photo, item: ImageItem)] = []
    private var currentPhotosPage = 0
    
    // MARK: - Services
    private let taskManager = GroupedTasksManager<TaskGroup, UUID>()
    private let dateFormatter = DisplayDateFormatter()
    
    private let photoDataRepo: PhotoDataRepositoryProtocol
    private let imagesRepo: ImagesRepositoryProtocol
    
    init(
        photoDataRepo: PhotoDataRepositoryProtocol,
        imagesRepo: ImagesRepositoryProtocol,
    ) {
        self.photoDataRepo = photoDataRepo
        self.imagesRepo = imagesRepo
    }
    
    func fetchPhotosData() {
        let pageKey = UUID()
        let taskKey = taskManager.makeKey(
            group: .photoData,
            taskID: pageKey
        )
        
        guard taskManager.get(for: taskKey) == nil else { return }
        
        updatePhotosState(.loading)
        currentPhotosPage += 1
        
        let task = Task {
            do {
                let newPhotos = try await photoDataRepo.fetch(
                    page: currentPhotosPage,
                    size: 20
                )
                
                try Task.checkCancellation()
                
                ///На стороне Unsplash баг с дупликатами
                ///Использую костыль ниже
                let cleanPhotos = Array(newPhotos.prefix(17))
                
                let photoItems: [PhotoItem] = makePhotoItems(cleanPhotos)
                
                let data: [(data: Photo, item: ImageItem)] = zip(cleanPhotos, photoItems).map({
                    ($0, ImageItem(id: $1.id))
                })
                
                photoEntries.append(contentsOf: data)
                updatePhotosState(.loaded(photoItems))
            } catch {
                currentPhotosPage -= 1
                updatePhotosState(.failed(error))
            }
            taskManager.remove(for: taskKey)
        }
        taskManager.set(task: task, for: taskKey)
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
    
        let taskKey = taskManager.makeKey(
            group: .imageItem,
            taskID: UUID()
        )
        
        guard taskManager.get(for: taskKey) == nil,
              photoEntries[index].item.image == nil,
              photoEntries.count > index
        else { return }
        
        let url = photoEntries[index].data.urls.small
        
        let task = Task {
            do {
                let image = try await imagesRepo.fetchImage(with: url)
                photoEntries[index].item.image = image
                imagePublisher.send(photoEntries[index].item)
            } catch {
                print(error)
            }
            taskManager.remove(for: taskKey)
        }
        taskManager.set(task: task, for: taskKey)
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

private extension PhotosViewModel {
    enum TaskGroup {
        case photoData
        case imageItem
    }
}
