//
//  PhotoLikeService.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 16.10.2025.
//

import Foundation
import NetworkKit
import HelpersSharedUnsp

protocol PhotoLikeServiceProtocol: Sendable {
    func like(photoID: String, token: String) async throws(NetworkError) -> PhotoDTO
    func unlike(photoID: String, token: String) async throws(NetworkError) -> PhotoDTO
}

final class PhotoLikeService: PhotoLikeServiceProtocol {
    
    private let requestFactory: NetworkRequestFactory
    private let helper: NetworkServiceHelper
    private let session: URLSession
    
    init(
        requestFactory: NetworkRequestFactory,
        helper: NetworkServiceHelper,
        session: URLSession = .shared,
    ) {
        self.requestFactory = requestFactory
        self.helper = helper
        self.session = session
    }
    
    func like(photoID: String, token: String) async throws(NetworkError) -> PhotoDTO {
        try await performRequest(id: photoID, token: token, method: .post)
    }
    
    func unlike(photoID: String, token: String) async throws(NetworkError) -> PhotoDTO {
        try await performRequest(id: photoID, token: token, method: .delete)
    }
}

private extension PhotoLikeService {
    func performRequest(id: String, token: String, method: HTTPMethod) async throws(NetworkError) -> PhotoDTO {
        guard let url = makeURL(withID: id) else {
            throw .invalidURL
        }
        
        print(url)
        
        let request = requestFactory.makeURLRequest(
            for: url,
            token: token,
            method: method
        )
        
        do {
            let (data, resp) = try await session.data(for: request)
            
            try helper.handle(response: resp)
            return try helper.handle(data: data) 
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw .transport(underlying: error)
        }
    }
    
    func makeURL(withID id: String) -> URL? {
        URLBuilder()
            .scheme(Scheme.https.rawValue)
            .host(Host.apiUnsplash.rawValue)
            .path(Path.build([.photos, .id(id), .like]))
            .build()
    }
}
