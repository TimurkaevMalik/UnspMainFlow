//
//  PhotosSearchViewModel.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 18.10.2025.
//

import Foundation
import Combine

protocol PhotosSearchViewModelProtocol: PhotosViewModelProtocol {
    typealias PhotosState = PhotoDataServiceState
    func fetchPhotosData(query: String)
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
    
    // MARK: - Pagination
    private var currentPage = 0
    
    // MARK: - Services
    private let taskManager = GropedTasksManager<TaskGroup, UUID>()
    private let dateFormatter = DisplayDateFormatter()
    
    private let photoDataRepo: PhotoDataRepositoryProtocol
    private let photoSearchRepo: PhotosSearchRepositoryProtocol
    private let imagesRepo: ImagesRepositoryProtocol
    
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
    
    func fetchPhotosData() {
        let source: Source = .feed
        updateSourceIfNeeded(source)
        fetch(from: source)
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
        var ids = ["1111", "2222", "3333", "4444", "5555", "6666", "7777", "8888"]
    
        if source != .feed {
            taskManager.removeAll()
            searchedPhotoEntries.removeAll()
            updatePhotosState(.loaded([]))
            currentPage = 0
        }
        let id = ids.randomElement()!
        let taskID = UUID()
        
        let taskKey = taskManager.makeKey(.init(
            group: .photoData,
            taskID: taskID
        ))
        
        guard taskManager.get(for: taskKey) == nil else { return }
        
        updatePhotosState(.loading)
        currentPage += 1
        
        let task = Task {
            print("start", id)
            do {
                let newPhotos: [Photo]
                
                switch source {
                case .feed:
                    print("started data task", id)
                    newPhotos = try await photoDataRepo.fetch(
                        page: currentPage,
                        size: 20
                    )
                case .search(let query):
                    print("started search task", id)
                    newPhotos = try await photoSearchRepo.fetch(
                        page: currentPage,
                        size: 20,
                        query: query
                    )
                }
                print("finished task", id)
                try Task.checkCancellation()
                print("Checked cancellation")
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
//                currentPage -= 1
                print("currentPage", currentPage, ". id", id)
                updatePhotosState(.failed(error))
            }
            print("didcome for", taskManager.get(for: taskKey), "with id", id)
            taskManager.remove(for: taskKey)
        }
        
        taskManager.set(task: task, for: taskKey)
    }
    
    func fetchImage(at index: Int) {
        let taskID = UUID()
        let taskKey = taskManager.makeKey(.init(
            group: .imageItem,
            taskID: taskID
        ))
        
        guard taskManager.get(for: taskKey) == nil,
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
            
            taskManager.remove(for: taskKey)
        }
        
        taskManager.set(task: task, for: taskKey)
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
        taskManager.removeAll()
        
        switch source {
        case .feed:
            searchedPhotoEntries.removeAll()
        case .search:
            feedPhotoEntries.removeAll()
        }
    }
}

private extension PhotosSearchViewModel {
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
