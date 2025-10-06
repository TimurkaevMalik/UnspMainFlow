//
//  NetworkContants.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 06.10.2025.
//

import Foundation

#warning("remove token")
let token = ""

enum QueryItemNames: String {
    case page = "page"
    case perPage = "per_page"
}

enum HTTPHeaderField: String {
    case acceptVersion = "Accept-Version"
    case authorization = "Authorization"
}

enum HTTPHeaderValue {
    case bearer(String)
    
    var value: String {
        switch self {
        case .bearer(let string):
            "Bearer \(string)"
        }
    }
}
