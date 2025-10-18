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
    typealias State = PhotoDataServiceState
    
    var photosState: PassthroughSubject<State, Never> { get }
    var imagePublisher: PassthroughSubject<ImageItem, Never> { get }
    
    func fetchPhotosData(query: String)
    func fetchImages(for indexes: [Int])
    
    func imageItem(at index: Int) -> ImageItem
    func photoItem(at index: Int) -> PhotoItem
}

final class PhotosSearchViewModel: PhotosSearchViewModelProtocol {
    enum Mode {
        case regular
        case searching
    }
    
    private var mode: Mode = .regular
    
    // MARK: - Subjects
    let photosState: PassthroughSubject<State, Never> = .init()
    let imagePublisher: PassthroughSubject<ImageItem, Never> = .init()
    
    // MARK: - Entries
    private var photoEntries: [(data: Photo, item: ImageItem)] {
        if mode == .regular {
            defaultPhotoEntries
        } else {
            searchedPhotoEntries
        }
    }
    private var defaultPhotoEntries: [(data: Photo, item: ImageItem)] = []
    private var searchedPhotoEntries: [(data: Photo, item: ImageItem)] = []
    
    // MARK: - Tasks
    private var imageItemTasks: [Int: Task<(), Never>] = [:]
    private var defaultPhotosPageTasks: [Int: Task<(), Never>] = [:]
    private var searchedPhotosPageTasks: [Int: Task<(), Never>] = [:]
    
    // MARK: - Pagination
    private var currentDefaultPhotosPage = 0
    private var currentSearchedPhotosPage = 0
    
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
        if query.isEmpty {
            fetchFromPhotoDataRepo()
        } else {
            fetchFromSearchPhotoDataRepo(query: query)
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
    func fetchFromPhotoDataRepo() {
        currentSearchedPhotosPage = 0
        guard defaultPhotosPageTasks[currentDefaultPhotosPage + 1] == nil else { return
        }
        
        updatePhotosState(.loading)
        currentDefaultPhotosPage += 1
        let pageKey = currentDefaultPhotosPage
        
        let task = Task {
            do {
                var newPhotos = try await photoDataRepo.fetch(
                    page: currentDefaultPhotosPage,
                    size: 20
                )
                
                ///На стороне Unsplash баг с дупликатами
                ///Использую костыль ниже
                newPhotos.removeLast(3)
                
                let photoItems: [PhotoItem] = makePhotoItems(newPhotos)
                
                let data: [(data: Photo, item: ImageItem)] = zip(newPhotos, photoItems).map({
                    ($0, ImageItem(id: $1.id))
                })
                
                defaultPhotoEntries.append(contentsOf: data)
                updatePhotosState(.loaded(photoItems))
            } catch {
                updatePhotosState(.failed(error))
            }
            
            defaultPhotosPageTasks.removeValue(forKey: pageKey)
        }
        
        defaultPhotosPageTasks[pageKey] = task
    }
    
    func fetchFromSearchPhotoDataRepo(query: String) {
        currentDefaultPhotosPage = 0
        guard searchedPhotosPageTasks[currentSearchedPhotosPage + 1] == nil else { return
        }
        
        updatePhotosState(.loading)
        currentSearchedPhotosPage += 1
        let pageKey = currentSearchedPhotosPage
        
        let task = Task {
            do {
                var newPhotos = try await photoSearchRepo.fetch(
                    page: currentSearchedPhotosPage,
                    size: 20,
                    query: query
                )
                
                newPhotos.removeLast(3)
                
                let photoItems: [PhotoItem] = makePhotoItems(newPhotos)
                
                let data: [(data: Photo, item: ImageItem)] = zip(newPhotos, photoItems).map({
                    ($0, ImageItem(id: $1.id))
                })
                
                searchedPhotoEntries.append(contentsOf: data)
                updatePhotosState(.loaded(photoItems))
            } catch {
                updatePhotosState(.failed(error))
            }
            
            searchedPhotosPageTasks.removeValue(forKey: pageKey)
        }
        
        searchedPhotosPageTasks[pageKey] = task
    }
    
    func fetchImage(at index: Int) {
        guard imageItemTasks[index] == nil,
              photoEntries[index].item.image == nil,
              photoEntries.count > index
        else { return }
        
        let url = photoEntries[index].data.urls.small
        
        let task = Task {
            do {
                let image = try await imagesRepo.fetchImage(with: url)
                
                if mode == .regular {
                    defaultPhotoEntries[index].item.image = image
                } else {
                    searchedPhotoEntries[index].item.image = image
                }
                
                imagePublisher.send(photoEntries[index].item)
            } catch {
                print(error)
            }
            
            imageItemTasks.removeValue(forKey: index)
        }
        
        imageItemTasks[index] = task
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
    
    func updatePhotosState(_ state: State) {
        photosState.send(state)
    }
    
    func updateMode(_ mode: Mode) {
        self.mode = mode
    }
}
