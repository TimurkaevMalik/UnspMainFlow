//
//  ImageService.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 12.10.2025.
//

import UIKit
import NetworkKit

protocol ImageServiceProtocol: Sendable {
    func fetchImage(with url: String) async throws -> UIImage
}

final class ImageService: ImageServiceProtocol {
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }
    
    func fetchImage(with url: String) async throws(NetworkError) -> UIImage {
        guard let url = URL(string: url) else { throw .invalidURL }
        
        do {
            let (data, response) = try await session.data(for: makeRequest(for: url))
            
            try handle(response: response)
            return try handle(data: data)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw .transport(underlying: error)
        }
    }
}

private extension ImageService {
    func makeRequest(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        return request
    }
    
    func handle(response: URLResponse) throws(NetworkError) {
        guard let response = response as? HTTPURLResponse else {
            throw .transport(underlying: URLError(.badServerResponse))
        }
        
        guard (200...299).contains(response.statusCode) else {
            throw .httpStatus(response.statusCode, nil)
        }
    }
    
    func handle(data: Data) throws(NetworkError) -> UIImage {
        if let image = UIImage(data: data) {
            return image
        }
        
        throw .decodingFailed(underlying: NSError(
            domain: "ImageDecoding",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Failed to decode image"]
        ))
    }
}
