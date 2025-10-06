//
//  FetchPhotosService.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 06.10.2025.
//

import Foundation
import NetworkKit
import HelpersSharedUnsp

protocol FetchPhotosServiceProtocol {
    func fetchPhotos(
        page: Int,
        size: Int,
        token: String
    ) async throws(NetworkError) -> [PhotoDTO]
}

#warning("Реализовать механизм retry")
final class FetchPhotosService: FetchPhotosServiceProtocol {
    
    private let decoder: JSONDecoder
    let session: URLSession
    
    init(
        decoder: JSONDecoder = JSONDecoder(),
        session: URLSession = .shared
    ) {
        self.decoder = decoder
        self.session = session
    }
    
    func fetchPhotos(
        page: Int,
        size: Int = 10,
        token: String
    ) async throws(NetworkError) -> [PhotoDTO] {
        
        guard let url = makeURL(page: page, size: size) else {
            throw .invalidURL
        }
        
        let request = makeURLRequest(for: url, token: token)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            try handle(response: response)
            let photos = try handle(data: data)
            return photos
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw .transport(underlying: error)
        }
    }
}

private extension FetchPhotosService {
    func handle(response: URLResponse) throws {
        guard let httpResp = response as? HTTPURLResponse else {
            throw NetworkError.transport(underlying: URLError(.badServerResponse))
        }
        
        guard (200..<300).contains(httpResp.statusCode) else {
            throw NetworkError.httpStatus(httpResp.statusCode)
        }
    }
    
    func handle(data: Data) throws -> [PhotoDTO] {
        do {
            print(data)
            return try decoder.decode([PhotoDTO].self, from: data)
        } catch {
            throw NetworkError.decodingFailed(underlying: error)
        }
    }
    
    func makeURLRequest(for url: URL, token: String) -> URLRequest {
        let acceptVersion = HTTPHeaderField.acceptVersion.rawValue
        let authorization = HTTPHeaderField.authorization.rawValue
        let accept = HTTPHeaderField.accept.rawValue
        
        let bearerValue = HTTPHeaderValue.bearer(token).value
        let apiVersionValue = HTTPHeaderValue.apiVersion.value
        let apiJsonValue = HTTPHeaderValue.appJSON.value
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue(bearerValue, forHTTPHeaderField: authorization)
        request.addValue(apiVersionValue, forHTTPHeaderField: acceptVersion)
        request.addValue(apiJsonValue, forHTTPHeaderField: accept)
        
        return request
    }
    
    func makeURL(page: Int, size: Int) -> URL? {
        URLBuilder()
            .scheme(Scheme.https.rawValue)
            .host(Host.apiUnsplash.rawValue)
            .path(Path.build([.photos]))
            .queryItem(name: QueryItemNames.perPage.rawValue, value: "\(size)")
            .queryItem(name: QueryItemNames.page.rawValue, value: "\(page)")
            .build()
    }
}
