# Feature Module Templates

Replace all placeholders before writing files:
- `{{FeatureName}}` → PascalCase feature name (e.g. `CardSettings`)
- `{{featureName}}` → camelCase feature name (e.g. `cardSettings`)
- `{{feature-name}}` → kebab-case (e.g. `card-settings`)
- `{{ModelName}}` → PascalCase model name (e.g. `Setting`)
- `{{modelName}}` → camelCase model name (e.g. `setting`)

---

## Project.swift

```swift
import ProjectDescription
import ProjectDescriptionHelpers

let project = CardsTrackerProject
    .frameworkWithInterface(
        name: "{{FeatureName}}",
        dependencies: [
            Dependency.utilities,
            Dependency.extensions,
            Dependency.navigation,
            Dependency.componentsUI,
            Dependency.resourcesUI,
            Dependency.coreServices,
            Dependency.coreModels
        ],
        interfaceDependencies: [
            Dependency.navigation
        ],
        targetDependencies: [
            .external(name: "Factory")
        ]
    )
    .build()
```

---

## {{FeatureName}}Strings.swift

```swift
//  {{FeatureName}}Strings.swift

import Foundation

enum {{FeatureName}}Strings {
    enum List {
        static let title = String(localized: "{{FeatureName}}.list.title")
    }
    enum Detail {
        static let title = String(localized: "{{FeatureName}}.detail.title")
    }
}
```

---

## Models/{{ModelName}}.swift

```swift
//  {{ModelName}}.swift

import Foundation

public struct {{ModelName}}: Identifiable, Hashable, Codable {
    public let id: String
    // Add model properties here
}

// MARK: - Mock

extension {{ModelName}} {
    static func mock(
        id: String = "mock-id"
    ) -> {{ModelName}} {
        .init(id: id)
    }
}
```

---

## Repository/{{FeatureName}}RepositoryProtocol.swift

```swift
//  {{FeatureName}}RepositoryProtocol.swift

import CoreModels

protocol {{FeatureName}}RepositoryProtocol {
    func fetch{{ModelName}}s() async -> Result<[{{ModelName}}], ServerError>
}
```

---

## Repository/{{FeatureName}}Repository.swift

```swift
//  {{FeatureName}}Repository.swift

import Foundation
import Factory
import CoreModels
import CoreServices

final class {{FeatureName}}Repository: {{FeatureName}}RepositoryProtocol {

    private enum RequestPath: String {
        case items = "MockData/{{featureName}}.json"

        var baseUrl: String {
            "https://raw.githubusercontent.com/sebastianburrieza/cards-tracker/main"
        }

        var url: URL? {
            URL(string: "\(baseUrl)/\(rawValue)")
        }
    }

    private let networkService: any NetworkServiceProtocol

    init(networkService: any NetworkServiceProtocol) {
        self.networkService = networkService
    }

    func fetch{{ModelName}}s() async -> Result<[{{ModelName}}], ServerError> {
        guard let url = RequestPath.items.url else {
            return .failure(ServerError(.invalidURL))
        }
        let request = URLRequest(url: url)
        do {
            let items = try await networkService.request([{{ModelName}}].self, for: request)
            return .success(items)
        } catch let error as ServerError {
            return .failure(error)
        } catch let error as NetworkError {
            return .failure(error.asServerError())
        } catch {
            return .failure(.unexpected)
        }
    }
}

// MARK: - Container

extension Container {
    var {{featureName}}Repository: Factory<any {{FeatureName}}RepositoryProtocol> {
        self { {{FeatureName}}Repository(networkService: self.networkService()) }.singleton
    }
}
```

---

## List/ListViewModel.swift

```swift
//  ListViewModel.swift

import SwiftUI
import Factory
import CoreModels

protocol {{FeatureName}}ListNavigationDelegate: AnyObject {
    func navigateToDetail(item: {{ModelName}})
    func showError(_ error: ServerError)
}

@Observable
final class ListViewModel {

    var items: [{{ModelName}}] = []
    var isLoading = false

    @ObservationIgnored
    @Injected(\.{{featureName}}Repository) private var repository

    weak var delegate: {{FeatureName}}ListNavigationDelegate?

    func fetchItems() async {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { self.isLoading = false } } }

        let result = await repository.fetch{{ModelName}}s()

        await MainActor.run {
            switch result {
            case .success(let items):
                self.items = items
            case .failure(let error):
                delegate?.showError(error)
            }
        }
    }
}
```

---

## List/ListView.swift

```swift
//  ListView.swift

import SwiftUI
import CoreModels

struct ListView: View {

    let viewModel: ListViewModel

    var body: some View {
        List(viewModel.items) { item in
            Text(item.id)
                .onTapGesture {
                    viewModel.delegate?.navigateToDetail(item: item)
                }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
        .task {
            await viewModel.fetchItems()
        }
    }
}
```

---

## List/ListViewController.swift

```swift
//  ListViewController.swift

import UIKit
import SwiftUI
import CoreModels

final class ListViewController: UIViewController {

    let viewModel: ListViewModel
    weak var coordinator: ListCoordinator?

    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        embedSwiftUIView(ListView(viewModel: viewModel))
    }
}

// MARK: - {{FeatureName}}ListNavigationDelegate

extension ListViewController: {{FeatureName}}ListNavigationDelegate {

    func navigateToDetail(item: {{ModelName}}) {
        coordinator?.navigate(to: .detail(item))
    }

    func showError(_ error: ServerError) {
        // TODO: show error alert
    }
}

// MARK: - Helpers

private extension UIViewController {
    func embedSwiftUIView(_ view: some View) {
        let host = UIHostingController(rootView: view)
        addChild(host)
        view_: host.view
        view_.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view_)
        NSLayoutConstraint.activate([
            view_.topAnchor.constraint(equalTo: self.view.topAnchor),
            view_.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            view_.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            view_.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
        host.didMove(toParent: self)
    }
}
```

---

## Detail/{{FeatureName}}DetailViewModel.swift

```swift
//  {{FeatureName}}DetailViewModel.swift

import SwiftUI
import CoreModels

protocol {{FeatureName}}DetailNavigationDelegate: AnyObject {
    func navigateToPrevious()
    func showError(_ error: ServerError)
}

@Observable
final class {{FeatureName}}DetailViewModel {

    let item: {{ModelName}}

    weak var delegate: {{FeatureName}}DetailNavigationDelegate?

    init(item: {{ModelName}}) {
        self.item = item
    }
}
```

---

## Detail/{{FeatureName}}DetailView.swift

```swift
//  {{FeatureName}}DetailView.swift

import SwiftUI
import CoreModels

struct {{FeatureName}}DetailView: View {

    let viewModel: {{FeatureName}}DetailViewModel

    var body: some View {
        Text(viewModel.item.id)
    }
}
```

---

## Detail/{{FeatureName}}DetailViewController.swift

```swift
//  {{FeatureName}}DetailViewController.swift

import UIKit
import SwiftUI

final class {{FeatureName}}DetailViewController: UIViewController {

    let viewModel: {{FeatureName}}DetailViewModel

    init(viewModel: {{FeatureName}}DetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        let host = UIHostingController(rootView: {{FeatureName}}DetailView(viewModel: viewModel))
        addChild(host)
        host.view.frame = view.bounds
        view.addSubview(host.view)
        host.didMove(toParent: self)
    }
}

// MARK: - {{FeatureName}}DetailNavigationDelegate

extension {{FeatureName}}DetailViewController: {{FeatureName}}DetailNavigationDelegate {

    func navigateToPrevious() {
        navigationController?.popViewController(animated: true)
    }

    func showError(_ error: ServerError) {
        // TODO: show error alert
    }
}
```

---

## Navigation/{{FeatureName}}RouteHandler.swift

```swift
//  {{FeatureName}}RouteHandler.swift

import UIKit
import Navigation
import {{FeatureName}}Interface

public final class {{FeatureName}}RouteHandler: RouteHandler {

    public init() { }

    public var routes: [any Route.Type] {
        [{{FeatureName}}Route.self]
    }

    @MainActor
    public func build(fromRoute route: (any Route)?) async -> UIViewController? {
        switch route {
        case is {{FeatureName}}Route:
            let viewModel = ListViewModel()
            return ListViewController(viewModel: viewModel)
        default:
            return nil
        }
    }
}
```

---

## Navigation/Coordinator/ListCoordinator.swift

```swift
//  ListCoordinator.swift

import UIKit
import Navigation
import CoreModels

public final class ListCoordinator: CoordinatorProtocol {

    public enum Steps {
        case home
        case detail({{ModelName}})
    }

    public var childCoordinators = [any CoordinatorProtocol]()
    public var navigationController: UINavigationController
    public var router: RouterProtocol

    public init(navigationController: UINavigationController, router: RouterProtocol) {
        self.navigationController = navigationController
        self.router = router
    }

    public func start() -> UIViewController {
        buildController(for: .home)
    }

    public func buildController(for step: Steps) -> UIViewController {
        switch step {
        case .home:
            let viewModel = ListViewModel()
            let controller = ListViewController(viewModel: viewModel)
            controller.coordinator = self
            return controller
        case .detail(let item):
            let coordinator = {{FeatureName}}DetailCoordinator(
                navigationController: navigationController,
                router: router,
                item: item
            )
            return coordinator.start()
        }
    }

    func navigate(to step: Steps) {
        let controller = buildController(for: step)
        navigationController.pushViewController(controller, animated: true)
    }
}
```

---

## Navigation/Coordinator/{{FeatureName}}DetailCoordinator.swift

```swift
//  {{FeatureName}}DetailCoordinator.swift

import UIKit
import Navigation
import CoreModels

public final class {{FeatureName}}DetailCoordinator: CoordinatorProtocol {

    public var childCoordinators = [any CoordinatorProtocol]()
    public var navigationController: UINavigationController
    public var router: RouterProtocol

    private let item: {{ModelName}}

    public init(navigationController: UINavigationController, router: RouterProtocol, item: {{ModelName}}) {
        self.navigationController = navigationController
        self.router = router
        self.item = item
    }

    public func start() -> UIViewController {
        let viewModel = {{FeatureName}}DetailViewModel(item: item)
        return {{FeatureName}}DetailViewController(viewModel: viewModel)
    }
}
```

---

## Navigation/DeepLink/{{FeatureName}}DeepLinkAction.swift

```swift
//  {{FeatureName}}DeepLinkAction.swift

import Foundation
import Navigation

public struct {{FeatureName}}DeepLinkAction: DeepLinkAction {

    private let queryParameters: [String: Any]
    private let routerService: any RouterServiceProtocol

    public init(queryParameters: [String: Any], routerService: any RouterServiceProtocol) {
        self.queryParameters = queryParameters
        self.routerService = routerService
    }

    public func execute() {
        routerService.navigate(to: {{FeatureName}}Route(), navigationType: .push(animated: true))
    }
}
```

---

## Navigation/DeepLink/{{FeatureName}}DeepLinkParser.swift

```swift
//  {{FeatureName}}DeepLinkParser.swift

import Foundation
import Navigation

public struct {{FeatureName}}DeepLinkParser: DeepLinkParserProtocol {

    private enum NotificationType: String {
        case generic = "{{featureName}}"
    }

    private enum URLHost: String {
        case feature = "{{feature-name}}"
    }

    private let routerService: any RouterServiceProtocol

    public init(routerService: any RouterServiceProtocol) {
        self.routerService = routerService
    }

    public func action(fromNotification userInfo: [AnyHashable: Any]) -> (any DeepLinkAction)? {
        guard
            let type = userInfo["type"] as? String,
            NotificationType(rawValue: type) != nil
        else { return nil }

        return {{FeatureName}}DeepLinkAction(
            queryParameters: userInfo as? [String: Any] ?? [:],
            routerService: routerService
        )
    }

    public func action(fromURL url: URL) -> (any DeepLinkAction)? {
        guard
            let host = url.host,
            URLHost(rawValue: host) != nil
        else { return nil }

        let params = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?
            .reduce(into: [String: Any]()) { $0[$1.name] = $1.value ?? "" } ?? [:]

        return {{FeatureName}}DeepLinkAction(queryParameters: params, routerService: routerService)
    }
}
```

---

## {{FeatureName}}Interface/{{FeatureName}}RouteRegistry.swift

```swift
//  {{FeatureName}}RouteRegistry.swift

import Navigation

public enum {{FeatureName}}RouteRegistry: String {
    case list
}

public struct {{FeatureName}}Route: Route {

    public static var identifier: String {
        {{FeatureName}}RouteRegistry.list.rawValue
    }

    public init() { }
}
```

---

## {{FeatureName}}Tests/{{FeatureName}}Tests.swift

```swift
//  {{FeatureName}}Tests.swift

import XCTest
@testable import {{FeatureName}}

final class {{FeatureName}}Tests: XCTestCase { }
```
