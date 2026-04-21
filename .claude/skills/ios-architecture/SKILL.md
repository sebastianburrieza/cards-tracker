---
name: ios-architecture
description: iOS architecture review, code analysis, and design guidance for Swift/SwiftUI projects. Use this skill whenever the user asks to review Swift or SwiftUI code, check architecture decisions, evaluate navigation patterns, assess MVVM structure, review payment flows, analyze UIKit/SwiftUI interoperability, check testability, or asks "how should I architect this" for an iOS feature. Also use when the user pastes Swift code and asks for feedback, improvements, or a second opinion.
---

# iOS Architecture Skill

This skill reviews and guides iOS architecture decisions with a focus on clean, testable, visually polished code. It reflects the standards of a senior iOS developer with a strong visual sensibility and deep experience building production-grade apps — including complex payment flows, hybrid UIKit/SwiftUI codebases, and AI-integrated features.

## Core principles to apply in every review

**Correctness first, elegance second.** Code must be correct and safe before it can be elegant. Never use force unwrap (`!`). Prefer `guard let` or `if let` with meaningful fallbacks.

**Testability is architecture.** If a piece of code is hard to test, the architecture is wrong. MVVM should keep ViewModels free of UIKit/SwiftUI imports so they can be tested in isolation.

**Visual interactions matter.** Transitions, animations, and micro-interactions are part of the feature, not decorations. Flag any interaction that feels abrupt or mechanical.

**Prefer async/await over callbacks and Combine chains** unless Combine is already established in the codebase. Async/await is more readable and easier to test.

**Use `@Observable` (iOS 17+) instead of `@ObservableObject`.** For older targets, use `@ObservableObject` only when necessary.

---

## Architecture patterns

### Preferred: MVVM + Coordinator-style navigation

```
View (SwiftUI)
  └── ViewModel (@Observable or ObservableObject)
        └── Use Cases / Services
              └── Repositories / Network layer
```

Navigation is handled outside the View. Views should not know about other Views — they communicate intent via the ViewModel, which signals the coordinator.

### UIKit + SwiftUI interoperability

When SwiftUI navigation APIs are inconsistent or the target iOS version is below 16, prefer hosting SwiftUI views inside a `UIHostingController` managed by a UIKit coordinator. This pattern:
- Keeps complex navigation logic in UIKit where it's predictable
- Lets SwiftUI views remain pure and declarative
- Makes it easy to swap out individual screens without touching navigation logic

```swift
// Example pattern: coordinator hosting SwiftUI screens
protocol FlowCoordinator: AnyObject {
    func navigate(to step: FlowStep)
}

enum FlowStep {
    case confirmation(PaymentDetails)
    case success
    case failure(Error)
}
```

---

## Review checklist

When reviewing code, go through these in order:

### Safety
- [ ] No force unwraps (`!`) — suggest safe alternatives
- [ ] No implicit optionals unless there's a clear reason
- [ ] Error handling is explicit, not swallowed with `try?` in critical paths
- [ ] Memory management: check for retain cycles in closures (`[weak self]`)

### Architecture
- [ ] ViewModels contain no SwiftUI/UIKit imports (except for types like `Color` or `Image` when unavoidable)
- [ ] Business logic lives in ViewModels or Use Cases, not in Views
- [ ] Navigation is not triggered directly from Views (no `NavigationLink` with complex logic inside)
- [ ] Services and repositories are injected, not instantiated inside ViewModels

### Concurrency
- [ ] Async operations use `async/await`
- [ ] `@MainActor` is applied where UI updates happen
- [ ] No `DispatchQueue.main.async` nesting — prefer `await MainActor.run` or `@MainActor` annotations

### SwiftUI specifics
- [ ] `@Observable` used for iOS 17+ targets (not `@ObservableObject`)
- [ ] Views are broken into small, focused components
- [ ] State management is clear: `@State` for local, `@Binding` for parent-child, `@Environment` for shared app state
- [ ] Animations use `.animation(.default, value:)` — avoid implicit animations

### Testability
- [ ] ViewModels can be instantiated with mock dependencies
- [ ] Protocols define the boundary between layers
- [ ] Side effects (network, storage) are behind abstractions

### Visual quality
- [ ] Transitions between states are animated, not instant
- [ ] Loading and error states are handled and designed, not just functional
- [ ] Text, spacing and touch targets follow HIG guidelines

---

## Common patterns to suggest

### Safe async image loading
```swift
// Prefer this over manual URLSession in views
AsyncImage(url: url) { phase in
    switch phase {
    case .empty: ProgressView()
    case .success(let image): image.resizable()
    case .failure: Image(systemName: "photo")
    @unknown default: EmptyView()
    }
}
```

### ViewModel with @Observable (iOS 17+)
```swift
@Observable
final class PaymentViewModel {
    var state: PaymentState = .idle
    private let paymentService: PaymentServiceProtocol

    init(paymentService: PaymentServiceProtocol) {
        self.paymentService = paymentService
    }

    func confirm() async {
        state = .loading
        do {
            let result = try await paymentService.process()
            state = .success(result)
        } catch {
            state = .failure(error)
        }
    }
}
```

### Protocol-based service injection
```swift
protocol PaymentServiceProtocol {
    func process() async throws -> PaymentResult
}

// Production
final class PaymentService: PaymentServiceProtocol { ... }

// Tests
final class MockPaymentService: PaymentServiceProtocol { ... }
```

---

## Output format

Structure every review as:

### Summary
One paragraph with the overall assessment — what's good, what needs attention, and the priority order for changes.

### Issues
List each issue with:
- **Severity**: Critical / Warning / Suggestion
- **Location**: File + line or code snippet
- **Problem**: What's wrong and why it matters
- **Fix**: Concrete code suggestion

### What's working well
Acknowledge what's already good — this is important for the developer to know what patterns to keep.

### Architecture notes (if applicable)
For larger reviews, include higher-level observations about the overall structure and any patterns worth standardizing.

---

## CardsTracker context

CardsTracker is a personal iOS project. When reviewing code in this project:
- Assume SwiftUI-first architecture
- Prefer modern patterns (iOS 17+, `@Observable`, `async/await`)
- The owner has a strong visual sensibility — flag any UI interaction that feels incomplete or unpolished
- AI integration is in progress — flag opportunities to add on-device intelligence where appropriate (Core ML, Vision, natural language)
- Code should be clean enough to use as a portfolio piece
