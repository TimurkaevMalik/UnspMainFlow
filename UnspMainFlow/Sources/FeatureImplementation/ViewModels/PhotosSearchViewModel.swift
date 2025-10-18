//
//  PhotosSearchViewModel.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 18.10.2025.
//

import Foundation
import Combine

@MainActor
protocol PhotosSearchViewModelProtocol {
    typealias PhotosState = PhotoDataServiceState
    
    var photosState: PassthroughSubject<PhotosState, Never> { get }
    var imagePublisher: PassthroughSubject<ImageItem, Never> { get }
    
    func fetchPhotosData(query: String)
    func fetchImages(for indexes: [Int])
    
    func imageItem(at index: Int) -> ImageItem
    func photoItem(at index: Int) -> PhotoItem
}

final class PhotosSearchViewModel: PhotosSearchViewModelProtocol {
    
    private var currentSource: Source = .feed
    
    // MARK: - Subjects
    let photosState: PassthroughSubject<PhotosState, Never> = .init()
    let imagePublisher: PassthroughSubject<ImageItem, Never> = .init()
    
    // MARK: - Entries
    private var feedPhotoEntries: [(data: Photo, item: ImageItem)] = []
    private var searchedPhotoEntries: [(data: Photo, item: ImageItem)] = []
    private var photoEntries: [(data: Photo, item: ImageItem)] {
        currentSource == .feed ? feedPhotoEntries : searchedPhotoEntries
    }
    
    // MARK: - Tasks
    private var tasks: [TaskKey: Task<(), Never>] = [:]
    
    // MARK: - Pagination
    private var currentPage = 0
    
    // MARK: - Services
    private let photoDataRepo: PhotoDataRepositoryProtocol
    private let photoSearchRepo: PhotosSearchRepositoryProtocol
    private let imagesRepo: ImagesRepositoryProtocol
    private let dateFormatter = DisplayDateFormatter()
    
    // MARK: - Init
    init(
        photoDataRepo: PhotoDataRepositoryProtocol,
        photoSearchRepo: PhotosSearchRepositoryProtocol,
        imagesRepo: ImagesRepositoryProtocol
    ) {
        self.photoDataRepo = photoDataRepo
        self.photoSearchRepo = photoSearchRepo
        self.imagesRepo = imagesRepo
    }
    
    func fetchPhotosData(query: String) {
        let source: Source = query.isEmpty ? .feed : .search(query: query)
        updateSourceIfNeeded(source)
        fetch(from: source)
    }
    
    func fetchImages(for indexes: [Int]) {
        indexes.forEach({ fetchImage(at: $0) })
    }
    
    func imageItem(at index: Int) -> ImageItem {
        photoEntries[index].item
    }
    
    func photoItem(at index: Int) -> PhotoItem {
        let photoData = photoEntries[index]
        
        return PhotoItem(
            id: photoData.item.id,
            index: index,
            likes: photoData.data.likes,
            likedByUser: photoData.data.likedByUser,
            createdAt: dateFormatter.string(from: photoData.data.createdAt),
            description: photoData.data.description
        )
    }
}

// MARK: - Remote methods
private extension PhotosSearchViewModel {
    func fetch(from source: Source) {
        let pageKey = currentPage + 1
        let taskKey = TaskKey(group: .photoData, identifier: pageKey)
        
        guard tasks[taskKey] == nil else { return }
        
        updatePhotosState(.loading)
        
        
        let task = Task {
            do {
                let newPhotos: [Photo]
                
                switch source {
                case .feed:
                    newPhotos = try await photoDataRepo.fetch(
                        page: currentPage,
                        size: 20
                    )
                case .search(let query):
                    newPhotos = try await photoSearchRepo.fetch(
                        page: currentPage,
                        size: 20,
                        query: query
                    )
                }
                
                try Task.checkCancellation()
                currentPage += 1
                
                ///На стороне Unsplash баг с дупликатами
                ///Использую костыль ниже
                let cleanPhotos = Array(newPhotos.prefix(17))
                
                let photoItems: [PhotoItem] = makePhotoItems(cleanPhotos)
                
                let data: [(data: Photo, item: ImageItem)] = zip(cleanPhotos, photoItems).map({
                    ($0, ImageItem(id: $1.id))
                })
                
                switch source {
                case .feed:
                    feedPhotoEntries.append(contentsOf: data)
                case .search:
                    searchedPhotoEntries.append(contentsOf: data)
                }
                
                updatePhotosState(.loaded(photoItems))
            } catch {
                updatePhotosState(.failed(error))
            }
            
            tasks.removeValue(forKey: taskKey)
        }
        
        tasks[taskKey] = task
    }
    
    func fetchImage(at index: Int) {
        let taskKey = TaskKey(group: .imageItem, identifier: index)
        
        guard tasks[taskKey] == nil,
              photoEntries.count > index,
              photoEntries[index].item.image == nil
        else { return }
                
        let url = photoEntries[index].data.urls.small
        
        let task = Task {
            do {
                let image = try await imagesRepo.fetchImage(with: url)
                
                if currentSource == .feed {
                    feedPhotoEntries[index].item.image = image
                } else {
                    searchedPhotoEntries[index].item.image = image
                }
                
                imagePublisher.send(photoEntries[index].item)
            } catch {
                print(error)
            }
            
            tasks.removeValue(forKey: taskKey)
        }
        tasks[taskKey] = task
    }
}

// MARK: - Local methods
private extension PhotosSearchViewModel {
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
    
    func updatePhotosState(_ state: PhotosState) {
        photosState.send(state)
    }
    
    func updateSourceIfNeeded(_ source: Source) {
        guard currentSource != source else { return }
        
        currentSource = source
        currentPage = 0
        tasks.forEach({ $0.value.cancel() })
        
        switch source {
        case .feed:
            searchedPhotoEntries = []
        case .search:
            feedPhotoEntries = []
        }
    }
}

private extension PhotosSearchViewModel {
    struct TaskKey: Hashable {
        let group: TaskGroup
        let identifier: Int
    }
    
    enum TaskGroup {
        case photoData
        case imageItem
    }
    
    enum Source: Equatable {
        case feed
        case search(query: String = "")
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
                
            case (.feed, .feed): true
            case (.search, .search): true
            default: false
            }
        }
    }
}
