//
//  DisplayDateFormatter.swift
//  UnspMainFlow
//
//  Created by Malik Timurkaev on 12.10.2025.
//

import  Foundation

final class DisplayDateFormatter {
    private let formatter: DateFormatter
    
    init() {
        formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.doesRelativeDateFormatting = true
    }
    
    func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
