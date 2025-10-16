//
//  PhotoLikeViewModel.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 16.10.2025.
//

import UIKit
import Combine

@MainActor
protocol PhotoLikeViewModelProtocol {
    var photoItemPublisher: CurrentValueSubject<PhotoItem, Never> { get }
    var imagePublisher: CurrentValueSubject<UIImage?, Never> { get }
    
    func like()
    func unlike()
}

final class PhotoLikeViewModel: PhotoLikeViewModelProtocol {
    
    var photoItemPublisher: CurrentValueSubject<PhotoItem, Never>
    var imagePublisher: CurrentValueSubject<UIImage?, Never>
    
    private let likeRepo: PhotoLikeRepositoryProtocol
    private let dateFormatter = DisplayDateFormatter()
    
    init(
        likeRepo: PhotoLikeRepositoryProtocol,
        photoItem: PhotoItem,
        image: UIImage
    ) {
        self.likeRepo = likeRepo
        photoItemPublisher = .init(photoItem)
        imagePublisher = .init(image)
    }
    
    func like() {
        Task {
            do {
                let likedPhoto = try await likeRepo.like(photoID: photoItemPublisher.value.id)
                
                let item = makePhotoItem(likedPhoto)
                photoItemPublisher.send(item)
            } catch {
                print(error)
            }
        }
    }
    
    func unlike() {
        Task {
            do {
                let unlikedPhoto = try await likeRepo.unlike(photoID: photoItemPublisher.value.id)
                
                let item = makePhotoItem(unlikedPhoto)
                photoItemPublisher.send(item)
            } catch {
                print(error)
            }
        }
    }
}

private extension PhotoLikeViewModel {
    func makePhotoItem(_ photo: Photo) -> PhotoItem {
        PhotoItem(
            id: photo.id,
            index: photoItemPublisher.value.index,
            likes: photo.likes,
            likedByUser: photo.likedByUser,
            createdAt: string(from: photo.createdAt),
            description: photo.description
        )
    }
    
    func string(from date: Date) -> String {
        dateFormatter.string(from: date)
    }
}
