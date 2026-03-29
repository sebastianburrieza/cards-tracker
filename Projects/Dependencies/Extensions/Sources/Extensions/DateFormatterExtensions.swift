//  DateFormatterExtensions.swift
//  Created by Catalina Burrieza on 01/04/2026.

import Foundation

extension DateFormatter {

    public static var shortMonthYearDateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "es")
        return dateFormatter
    }

    public static var dayNumberFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }

    public static var dayMonthYearLongFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "d 'de' MMMM 'de' yyyy"
        formatter.locale = Locale(identifier: "es")
        return formatter
    }
}
