//  Bundle+CardsTransactionDetail.swift

import Foundation

private final class BundleFinder {}

extension Bundle {
    static var cardsTransactionDetail: Bundle {
        let bundle = Bundle(for: BundleFinder.self)
        guard let path = bundle.path(forResource: "CardsTransactionDetail", ofType: "bundle"),
              let newBundle = Bundle(path: path)
        else {
            return .main
        }
        return newBundle
    }
}
