//  String+Localized.swift
//  Created by Sebastian Burrieza on 2/04/2026.

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: .authentication, comment: "")
    }

    func localized(_ args: CVarArg...) -> String {
        String(format: self.localized, arguments: args)
    }
}
