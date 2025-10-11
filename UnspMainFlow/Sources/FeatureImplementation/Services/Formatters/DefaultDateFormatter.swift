//
//  DefaultDateFormatter.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 07.10.2025.
//

import Foundation

final class DefaultDateFormatter {
    
    private let formatter: DateFormatter
    
    init() {
        formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
    }
    
    func date(from string: String) -> Date? {
        return formatter.date(from: string) ?? nil
    }
}
