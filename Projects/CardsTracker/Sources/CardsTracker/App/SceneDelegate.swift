//  SceneDelegate.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import UserNotifications
import Factory
import Navigation

final class SceneDelegate: NSObject, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    @Injected(\.deepLinkHandler) private var deepLinkHandler

    // MARK: - UIWindowSceneDelegate

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let navController = UINavigationController()
        navController.navigationBar.isHidden = true

        let appCoordinator = AppCoordinator(navigationController: navController)
        self.appCoordinator = appCoordinator

        // Receive foreground notifications in this scene.
        UNUserNotificationCenter.current().delegate = self

        // Configure routing services before any navigation occurs.
        AppRouter.setup(router: appCoordinator.router)

        // Queue cold-start triggers so they execute once the window is ready.
        if let response = connectionOptions.notificationResponse {
            deepLinkHandler.handle(notification: response.notification.request.content.userInfo)
        }
        if let url = connectionOptions.urlContexts.first?.url {
            deepLinkHandler.handle(url: url)
        }

        let rootViewController = appCoordinator.start()
        navController.viewControllers = [rootViewController]

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window

        // Execute any queued cold-start deep link now that the stack is ready.
        Task { await deepLinkHandler.processPendingIfNeeded() }
    }

    // MARK: - Deep link URLs (foreground)

    func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
        guard let url = urlContexts.first?.url else { return }
        Task { await deepLinkHandler.process(url: url) }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension SceneDelegate: UNUserNotificationCenterDelegate {

    /// Called when a notification is delivered while the app is in the foreground.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    /// Called when the user taps a notification while the app is running.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Task {
            await deepLinkHandler.process(notification: response.notification.request.content.userInfo)
            completionHandler()
        }
    }
}
