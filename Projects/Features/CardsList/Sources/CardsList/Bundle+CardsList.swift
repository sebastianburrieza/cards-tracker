//  Bundle+CardsList.swift

import Foundation

private final class BundleFinder {}

extension Bundle {
    static var cardsList: Bundle {
        let bundle = Bundle(for: BundleFinder.self)
        guard let path = bundle.path(forResource: "CardsList", ofType: "bundle"),
              let newBundle = Bundle(path: path)
        else {
            return .main
        }
        return newBundle
    }
}
