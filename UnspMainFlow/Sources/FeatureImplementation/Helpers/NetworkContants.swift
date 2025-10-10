//
//  NetworkContants.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 06.10.2025.
//

import Foundation

#warning("remove token")
let token = "0ZxCjq4iF-nGhW88JeFHY2z3e3ALKDwVLWedKZ42_3g"

enum QueryItemNames: String {
    case page = "page"
    case perPage = "per_page"
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
