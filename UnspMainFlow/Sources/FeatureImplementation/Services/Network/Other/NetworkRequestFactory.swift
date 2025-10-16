//
//  NetworkRequestFactory.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 16.10.2025.
//

import Foundation
import NetworkKit

protocol NetworkRequestFactory: Sendable {
    func makeURLRequest(for url: URL, token: String, method: HTTPMethod) -> URLRequest
}

final class AuthorizedRequestFactory: NetworkRequestFactory {
    
    func makeURLRequest(for url: URL, token: String, method: HTTPMethod) -> URLRequest {
        
        let acceptVersion = HTTPHeaderField.acceptVersion.rawValue
        let authorization = HTTPHeaderField.authorization.rawValue
        let accept = HTTPHeaderField.accept.rawValue
        
        let bearerValue = HTTPHeaderValue.bearer(token).value
        let apiVersionValue = HTTPHeaderValue.apiVersion.value
        let apiJsonValue = HTTPHeaderValue.appJSON.value
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue(bearerValue, forHTTPHeaderField: authorization)
        request.addValue(apiVersionValue, forHTTPHeaderField: acceptVersion)
        request.addValue(apiJsonValue, forHTTPHeaderField: accept)
        
        return request
    }
}
