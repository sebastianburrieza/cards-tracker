//  String+Localized.swift

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, bundle: .cardsTransactionDetail, comment: "")
    }

    func localized(_ args: CVarArg...) -> String {
        String(format: self.localized, arguments: args)
    }
}
