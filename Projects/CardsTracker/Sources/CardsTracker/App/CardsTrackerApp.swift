import SwiftUI

@main
struct CardsTrackerApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // La ventana y la navegación son manejadas por SceneDelegate + AppCoordinator
        WindowGroup { Color.clear.ignoresSafeArea() }
    }
}
