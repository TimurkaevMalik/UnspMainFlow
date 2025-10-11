//
//  ImagesRepository.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 12.10.2025.
//

import UIKit

@MainActor
protocol ImagesRepositoryProtocol {
    func fetchImage(with url: String) async throws -> UIImage
}

final class ImagesRepository: ImagesRepositoryProtocol {
    
    private let imageService: ImageServiceProtocol
    
    init(imageService: ImageServiceProtocol) {
        self.imageService = imageService
    }
    
    func fetchImage(with url: String) async throws -> UIImage {
        try await imageService.fetchImage(with: url)
    }
}
