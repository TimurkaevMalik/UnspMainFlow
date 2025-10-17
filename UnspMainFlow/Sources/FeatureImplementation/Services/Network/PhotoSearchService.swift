//
//  PhotoSearchService.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 18.10.2025.
//

import Foundation
import NetworkKit
import HelpersSharedUnsp

protocol PhotoSearchServiceProtocol: Sendable {
    func searchPhotos(
        page: Int,
        size: Int,
        query: String,
        token: String
    ) async throws(NetworkError) -> [PhotoDTO]
}

final class PhotoSearchService: PhotoSearchServiceProtocol {
    
    private let requestFactory: NetworkRequestFactory
    private let helper: NetworkServiceHelper
    private let session: URLSession
    
    init(
        requestFactory: NetworkRequestFactory,
        helper: NetworkServiceHelper,
        session: URLSession = .shared
    ) {
        self.helper = helper
        self.requestFactory = requestFactory
        self.session = session
    }
    
    func searchPhotos(
        page: Int,
        size: Int,
        query: String,
        token: String
    ) async throws(NetworkError) -> [PhotoDTO] {
        
        let url = makeURL(query: query, page: page, size: size)
        
        guard let url  else { throw .invalidURL }

        let request = requestFactory.makeURLRequest(
            for: url,
            token: token,
            method: .get
        )
        
        do {
            let (data, response) = try await session.data(for: request)
            
            try helper.handle(response: response)
            
            let searchedPhotos = try helper.handle(data: data) as SearchedPhotosDTO

            return searchedPhotos.results
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw .transport(underlying: error)
        }
    }
}

private extension PhotoSearchService {
    func makeURL(query: String, page: Int, size: Int) -> URL? {
        URLBuilder()
            .scheme(Scheme.https.rawValue)
            .host(Host.apiUnsplash.rawValue)
            .path(Path.build([.search, .photos]))
            .queryItem(name: QueryItemNames.query.rawValue, value: query)
            .queryItem(name: QueryItemNames.page.rawValue, value: "\(page)")
            .queryItem(name: QueryItemNames.perPage.rawValue, value: "\(size)")
            .build()
    }
}
