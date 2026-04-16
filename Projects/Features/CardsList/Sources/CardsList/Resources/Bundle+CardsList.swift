//  Bundle+CardsList.swift

import Foundation

private final class BundleFinder {}

extension Bundle {
    static var cardsList: Bundle {
        // For a DYNAMIC framework, Bundle(for:) returns the framework's own bundle directly.
        // For a STATIC framework (MACH_O_TYPE = staticlib), the class is merged into the
        // app's main executable at link time, so Bundle(for:) returns Bundle.main instead.
        let found = Bundle(for: BundleFinder.self)
        guard found == .main else { return found }

        // Static case: the .framework folder is still embedded in the app bundle at
        // Frameworks/CardsList.framework, and its lproj resources live inside there.
        // We need to construct the path manually because Bundle(for:) can't find it.
        if let url = Bundle.main.resourceURL?
            .appendingPathComponent("Frameworks")
            .appendingPathComponent("CardsList.framework"),
           let embedded = Bundle(url: url) {
            return embedded
        }

        // Last resort: resources were merged directly into the app bundle (e.g. during
        // unit tests where the framework isn't embedded).
        return .main
    }
}
