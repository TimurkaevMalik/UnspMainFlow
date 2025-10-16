//
//  FetchPhotosService.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 06.10.2025.
//

import Foundation
import NetworkKit
import HelpersSharedUnsp

protocol PhotosDataServiceProtocol: Sendable {
    func fetchPhotos(
        page: Int,
        size: Int,
        token: String
    ) async throws(NetworkError) -> [PhotoDTO]
}

final class PhotosDataService: PhotosDataServiceProtocol {
    
    private let requestFactory: NetworkRequestFactory
    private let helper: NetworkServiceHelper
    private let session: URLSession
    
    init(
        requestFactory: NetworkRequestFactory,
        helper: NetworkServiceHelper,
        session: URLSession = .shared
    ) {
        self.requestFactory = requestFactory
        self.helper = helper
        self.session = session
    }
    
    func fetchPhotos(
        page: Int,
        size: Int,
        token: String
    ) async throws(NetworkError) -> [PhotoDTO] {
        
        guard let url = makeURL(page: page, size: size) else {
            throw .invalidURL
        }
        
        let request = requestFactory.makeURLRequest(
            for: url,
            token: token,
            method: .get
        )
        
        do {
            let (data, response) = try await session.data(for: request)
            
            try helper.handle(response: response)
            return try helper.handle(data: data)
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw .transport(underlying: error)
        }
    }
}

private extension PhotosDataService {
    func makeURL(page: Int, size: Int) -> URL? {
        URLBuilder()
            .scheme(Scheme.https.rawValue)
            .host(Host.apiUnsplash.rawValue)
            .path(Path.build([.photos]))
            .queryItem(name: QueryItemNames.page.rawValue, value: "\(page)")
            .queryItem(name: QueryItemNames.perPage.rawValue, value: "\(size)")
            .build()
    }
}
