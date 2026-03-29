//  StringExtensions.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

extension String {

    public func replacingOccurrences(of mapAttributed: [String: AttributedString]) -> AttributedString {
        var attributedString = AttributedString(self)
        for (key, value) in mapAttributed {
            let occurrencesOfKey = attributedString.characters.map { String($0) }.joined(separator: key)
            (0...occurrencesOfKey.count - 1).forEach { _ in
                if let range = attributedString.range(of: key) {
                    attributedString.replaceSubrange(range, with: value)
                }
            }
        }
        return attributedString
    }
}
