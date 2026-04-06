---
name: ios-mvvm-pattern
description: Use when implementing ViewModels, async/await patterns, or delegate communication in iOS projects. Use this skill whenever the user mentions ViewModel, @Observable, async/await, delegate, MVVM, navigation delegate, Task, @MainActor, or asks to create any new feature screen — even if they don't explicitly mention MVVM.
---

# MVVM + Async/Await + Delegate Patterns

Apply these patterns when implementing features. This project targets iOS 17+ and uses `@Observable` — do NOT use `ObservableObject` or `@Published`.

## MVVM Architecture

### ViewModel Requirements

- Use `@Observable` macro (iOS 17+) — replaces `ObservableObject` + `@Published`
- Plain `var` properties are automatically observed — no `@Published` needed
- Use `@ObservationIgnored` for properties that should NOT trigger observation (e.g. `@Injected` from Factory)
- Use `await MainActor.run` to update state from async contexts
- Load data in `viewDidLoad`/`viewWillAppear` or `.task {}`, NOT in `init`
- Keep Views passive — only display data from ViewModel
- Always verify all required imports are present when generating new files

```swift
import SwiftUI
import Factory
import CoreModels

protocol FeatureNavigationDelegate: AnyObject {
    func navigateToDetail(card: Card)
    func showError(_ error: ServerError)
}

@Observable
final class FeatureViewModel {
    var items: [Item] = []
    var isLoading = false

    weak var delegate: FeatureNavigationDelegate?

    @ObservationIgnored
    @Injected(\.cardsRepository) private var repository

    init(card: Card) {
        self.card = card
        // NO loading logic here
    }

    func fetchData() async {
        await MainActor.run { isLoading = true }
        defer { Task { await MainActor.run { isLoading = false } } }

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

### Using @Observable ViewModels in Views

In views that **own** the ViewModel (create it), use `@State`:
```swift
struct FeatureView: View {
    @State private var viewModel = FeatureViewModel()
    ...
}
```

In views that **receive** the ViewModel from outside, use a plain property:
```swift
struct FeatureView: View {
    let viewModel: FeatureViewModel
    ...
}
```

Do NOT use `@ObservedObject` or `@StateObject` — those are for `ObservableObject` only.

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
- Avoid `@Published` — use plain `var` inside `@Observable` classes instead
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

- [ ] `@Observable` macro (NOT `ObservableObject`)
- [ ] `final class` declaration
- [ ] Plain `var` for observable state (NOT `@Published`)
- [ ] `@ObservationIgnored` before `@Injected` properties
- [ ] `weak var delegate` for navigation
- [ ] No loading in `init`
- [ ] Async methods for data operations
- [ ] `await MainActor.run` for UI state updates inside async functions
- [ ] Proper error handling with delegate
- [ ] All required imports present at the top of the file

### View Checklist

- [ ] `@State` for ViewModels owned by the View
- [ ] Plain `let viewModel` for ViewModels passed from outside
- [ ] No `@ObservedObject` or `@StateObject`

### Async/Await Checklist

- [ ] `Task` for sync-to-async bridging
- [ ] `async let` for parallel operations
- [ ] `await MainActor.run` for UI updates inside async contexts
