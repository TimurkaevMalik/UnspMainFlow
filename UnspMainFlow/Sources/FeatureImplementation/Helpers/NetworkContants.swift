//
//  NetworkContants.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 06.10.2025.
//

import Foundation

enum QueryItemNames: String {
    case page = "page"
    case perPage = "per_page"
    case query = "query"
}

enum HTTPHeaderValue {
    case bearer(String)
    case apiVersion
    case appJSON
    
    var value: String {
        switch self {
        case .bearer(let string):
            "Bearer \(string)"
        case .apiVersion:
            "v1"
        case .appJSON:
            "application/json"
        }
    }
}
