//
//  Date+Ext.swift
//  FreshStart
//
//  Created by Mert Köksal on 1.12.2024.
//

import Foundation

extension Date {
    // Method to format the date with a given format string
    func getFormattedDate(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    func toDDMMDateFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter.string(from: self)
    }
    // Default formatter for short date style without time
    func getShortDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    static func date(from string: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    static let subscriptionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.MM.yyyy"
        return formatter
    }()
    
    static func date(from string: String) -> Date? {
        return subscriptionDateFormatter.date(from: string)
    }
}


extension Date {
    static func mondayAt12AM() -> Date {
        return Calendar(identifier: .iso8601).date(
            from: Calendar(identifier: .iso8601)
                .dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())
        )!
    }
}

