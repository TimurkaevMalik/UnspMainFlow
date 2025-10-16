//
//  NetworkServiceHelper.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 16.10.2025.
//

import Foundation
import NetworkKit

#warning("Move to NetworkKit")
protocol NetworkServiceHelper: Sendable {
    func handle(response: URLResponse) throws
    func handle<T: Decodable>(data: Data) throws -> T
}

final class DefaultNetworkServiceHelper: NetworkServiceHelper {
    
    private let decoder: JSONDecoder
    
    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }
    
    func handle(response: URLResponse) throws {
        guard let httpResp = response as? HTTPURLResponse else {
            throw NetworkError.transport(underlying: URLError(.badServerResponse))
        }
        
        guard (200...299).contains(httpResp.statusCode) else {
            throw NetworkError.httpStatus(httpResp.statusCode)
        }
    }
    
    func handle<T: Decodable>(data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(underlying: error)
        }
    }
}
