---
name: ios-mvvm-pattern
description: Use when implementing ViewModels, async/await patterns, or delegate communication in iOS projets. Triggers - ViewModel, async/await, delegate, MVVM, navigation delegate, Task, @MainActor.
---

# MVVM + Async/Await + Delegate Patterns

Apply these patterns when implementing features.

## MVVM Architecture

### ViewModel Requirements

- Mark ViewModels with `@MainActor` only if it not has async functions
- Use `@Published` properties for UI-bound state
- Use `await MainActor.run` for UI-bound state properties that are between an async function call
- Load data in `viewDidLoad`/`viewWillAppear`, NOT in `init`
- Keep Views passive - only display data from ViewModel

```swift
protocol FeatureNavigationDelegate: AnyObject {
    func navigateToDetail(card: Card)
    func showError(_ error: ServerError)
}

@MainActor
final class FeatureViewModel: ObservableObject {
    @Published private(set) var items: [Item] = []
    @Published private(set) var isLoading = true
    @Published private(set) var error: ServerError?

    weak var delegate: FeatureNavigationDelegate?

    @Injected(\.cardsRepository) private var repository

    init(card: Card) {
        self.card = card
        // NO loading logic here
    }

    func fetchData() async {
        await MainActor.run {
            isLoading = true
        }
        defer { isLoading = false }

        let result = await repository.fetchItems()

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

### Model Guidelines

- Prefer `struct` over `class` for models
- Make models immutable when possible
- Implement `Equatable` and `Hashable` when appropriate
- Use protocols for interfaces between layers

## Async/Await Patterns

### Task Usage

Use `Task` for asynchronous operations from synchronous contexts:

```swift
func viewDidLoad() {
    super.viewDidLoad()
    Task {
        await viewModel.fetchData()
    }
}
```

### Concurrent Operations

Use `async let` for parallel independent operations:

```swift
func fetchAllData() async throws {
    async let user = userService.fetchUser()
    async let accounts = accountService.fetchAccounts()
    async let transactions = transactionService.fetchRecent()

    let (userData, accountsData, transactionsData) = try await (user, accounts, transactions)
    // Process all data together
}
```

### TaskGroup for Complex Parallelism

```swift
func processItems(_ items: [Item]) async throws -> [Result] {
    try await withThrowingTaskGroup(of: Result.self) { group in
        for item in items {
            group.addTask {
                try await self.processItem(item)
            }
        }

        var results: [Result] = []
        for try await result in group {
            results.append(result)
        }
        return results
    }
}
```

### Cancellation Handling

Use `withTaskCancellationHandler` for cleanup:

```swift
func fetchWithCleanup() async throws -> Data {
    try await withTaskCancellationHandler {
        try await performFetch()
    } onCancel: {
        cleanupResources()
    }
}
```

### Avoid Combine

- Prefer async/await over Combine
- Use `@Published` only for UI binding
- Avoid callbacks when async/await is possible

## Delegate Pattern

### Protocol Structure

Name delegates with `[Feature]NavigationDelegate` for navigation or `[Feature]Delegate` for general actions:

```swift
protocol FeatureNavigationDelegate: AnyObject {
    func navigateToBack()
    func navigateToDetail(_ item: Item)
    func showMoreInformation(for item: Item)
    func showError(_ error: ServerError)
    func endFlow(toRoot: Bool)
}
```

### Common Delegate Methods

| Method | Purpose |
|--------|---------|
| `navigateToBack()` | Return to previous screen |
| `navigateToDetail(_:)` | Navigate to detail view |
| `showMoreInformation(for:)` | Show additional info modal |
| `showError(_:)` | Display error to user |
| `endFlow(toRoot:)` | Complete and exit flow |

### ViewModel Implementation

Always use `weak var` to avoid retain cycles:

```swift
final class FeatureViewModel: ObservableObject {
    weak var delegate: FeatureNavigationDelegate?

    func handleItemSelected(_ item: Item) {
        delegate?.navigateToDetail(item)
    }

    func handleError(_ error: RestServerError) {
        delegate?.showError(error)
    }

    func handleFlowComplete() {
        delegate?.endFlow(toRoot: false)
    }
}
```

### Coordinator as Delegate

The Coordinator implements the delegate and handles navigation:

```swift
final class FeatureCoordinator: FeatureNavigationDelegate {
    private let navigationController: UINavigationController

    func navigateToBack() {
        navigationController.popViewController(animated: true)
    }

    func navigateToDetail(_ item: Item) {
        let detailVC = DetailViewController(item: item)
        navigationController.pushViewController(detailVC, animated: true)
    }

    func showError(_ error: RestServerError) {
        let alert = UIAlertController(/* configure for error */)
        navigationController.present(alert, animated: true)
    }

    func endFlow(toRoot: Bool) {
        if toRoot {
            navigationController.popToRootViewController(animated: true)
        } else {
            navigationController.popViewController(animated: true)
        }
    }
}
```

## SwiftUI + UIKit Integration

- Use SwiftUI for modern UI components
- Use UIKit for navigation (Coordinators)


## Quick Reference

### ViewModel Checklist

- [ ] `@MainActor` annotation if not async
- [ ] `final class` declaration
- [ ] `ObservableObject` conformance
- [ ] `@Published private(set)` for state
- [ ] `weak var delegate` for navigation
- [ ] No loading in `init`
- [ ] Async methods for data operations
- [ ] Proper error handling with delegate

### Async/Await Checklist

- [ ] `Task` for sync-to-async bridging
- [ ] `async let` for parallel operations
- [ ] `@MainActor` or `await MainActor.run` for UI updates
