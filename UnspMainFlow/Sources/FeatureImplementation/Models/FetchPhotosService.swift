//
//  FetchPhotosService.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 06.10.2025.
//

import Foundation
import NetworkKit

enum NetworkError: Error, Sendable {
    case invalidURL
    case httpStatus(Int, Data? = nil)
    case decodingFailed(underlying: Error)
    case transport(underlying: Error)
}

@propertyWrapper
struct DefaultEmptyString: Decodable {
    var wrappedValue: String
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(String.self)) ?? ""
    }
}

struct PhotoDTO: Decodable {
    let id: String
    let likes: Int
    let likedByUser: Bool
    let urls: PhotoURLs
    @DefaultEmptyString var description: String
    
    enum CodingKeys: String, CodingKey {
        case id, likes, description, urls
        case likedByUser = "liked_by_user"
    }
}

struct PhotoURLs: Decodable {
    let small: String
}

protocol FetchPhotosServiceProtocol {
    func fetchPhotos(
        page: Int,
        size: Int,
        token: String
    ) async throws(NetworkError) -> [PhotoDTO]
}

#warning("Реализовать механизм retry")
@MainActor
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
        let bearerValue = HTTPHeaderValue.bearer(token).value
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue(bearerValue, forHTTPHeaderField: authorization)
        request.addValue("v1", forHTTPHeaderField: acceptVersion)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    func makeURL(page: Int, size: Int) -> URL? {
        URLBuilder()
            .scheme(Scheme.https.rawValue)
            .host("api.unsplash.com")
            .path(Path.build([.photos]))
            .queryItem(name: QueryItemNames.perPage.rawValue, value: "\(size)")
            .queryItem(name: QueryItemNames.page.rawValue, value: "\(page)")
            .build()
    }
}
