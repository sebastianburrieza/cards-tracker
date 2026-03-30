---
name: ios-swiftui-view-pattern
description: Use when creating, editing, or reviewing SwiftUI Views or ViewModels in this project. Triggers - new View, new screen, SwiftUI struct, body, @ViewBuilder, @ObservedObject, ViewModel for a view, card component, list view, detail view, preview, Palette, Fonts, .task, .isSkeletonView, NavigationBar, safeAreaInset. Always apply this skill when the user asks to build or modify any SwiftUI UI — even if they just say "add a screen", "create a component", or "make a view for X".
---

# iOS SwiftUI View Patterns

Follow these patterns consistently when building or modifying any View or ViewModel in this project.

---

## View File Template

Use this as the starting point for any new screen or component:

```swift
import SwiftUI

// MARK: - View

struct FeatureView: View {

    @ObservedObject var viewModel: FeatureViewModel

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                content
            }
        }
        .safeAreaInset(edge: .top) {
            navigationBarView
                .background(Material.ultraThin)
        }
        .task { await viewModel.fetchData() }
    }
}

// MARK: - Subviews

private extension FeatureView {

    @ViewBuilder
    var background: some View {
        LinearGradient(
            colors: [
                Palette.primary.swiftUI.opacity(0.4),
                Palette.orange.swiftUI.opacity(0.2)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    @ViewBuilder
    var navigationBarView: some View {
        NavigationBarView(
            middleView: AnyView(
                Text(FeatureStrings.title)
                    .font(Fonts.medium(size: 21))
            )
        )
    }

    @ViewBuilder
    var content: some View {
        // Main content here
    }
}

// MARK: - Preview

#if DEBUG
struct FeatureView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = FeatureViewModel()
        return FeatureView(viewModel: vm)
    }
}
#endif
```

---

## ViewModel File Template

```swift
import Foundation
import Factory

// MARK: - Screen-level ViewModel (async, DI, delegation)

@MainActor
final class FeatureViewModel: ObservableObject {

    // MARK: Published state
    @Published private(set) var items: [Item] = []
    @Published private(set) var isLoading = true

    // MARK: Navigation
    weak var delegate: FeatureNavigationDelegate?

    // MARK: Dependencies
    @Injected(\.featureRepository) private var repository

    // MARK: Actions
    func fetchData() async {
        await MainActor.run { isLoading = true }
        defer { isLoading = false }

        let result = await repository.fetchItems()

        await MainActor.run {
            switch result {
            case .success(let items): self.items = items
            case .failure(let error): delegate?.showError(error)
            }
        }
    }
}
```

---

## View Structure Rules

### Break the body into `@ViewBuilder` computed properties

Never write a long `body`. Extract every logical section into a named private `@ViewBuilder` property. Each one should represent a single, cohesive piece of the UI.

```swift
// ✅ Correct
var body: some View {
    ZStack {
        background.ignoresSafeArea()
        cardList
    }
}

@ViewBuilder private var background: some View { ... }
@ViewBuilder private var cardList: some View { ... }

// ❌ Avoid — inline everything in body
var body: some View {
    ZStack {
        LinearGradient(...).ignoresSafeArea()
        ScrollView {
            VStack { ForEach(...) { ... } }
        }
    }
}
```

### Use MARK comments to label each section

```swift
// MARK: Background
@ViewBuilder
private var background: some View { ... }

// MARK: NavigationBar
@ViewBuilder
private var navigationBarView: some View { ... }

// MARK: Card list
@ViewBuilder
private var cardList: some View { ... }
```

### Layout primitives

- `ZStack` + `ignoresSafeArea()` on background for full-bleed gradients
- `.safeAreaInset(edge: .top)` for sticky headers (avoids layout conflicts with ScrollView)
- `VStack(spacing: 0)` as the main content container

---

## ViewModel Connection Rules

### Always use `@ObservedObject` — never `@StateObject`

ViewModels are injected from coordinators/outside, so `@StateObject` is wrong here.

```swift
// ✅
@ObservedObject var viewModel: ListViewModel

// ❌
@StateObject private var viewModel = ListViewModel()
```

### Load data with `.task`, not `.onAppear`

`.task` handles async/await natively and cancels automatically when the view disappears.

```swift
.task { await viewModel.fetchCards() }
```

### Two tiers of ViewModels

| Type | Purpose | Has DI? | Has delegate? |
|------|---------|---------|---------------|
| **Screen VM** | Manages screen state, calls services, delegates navigation | ✅ `@Injected` | ✅ `weak var delegate` |
| **Component VM** | Formats and transforms data for display | ❌ | ❌ |

Component ViewModels take a model in `init` and only expose computed display values:

```swift
final class CardListItemViewModel: ObservableObject {
    let card: Card

    init(card: Card) { self.card = card }

    var formattedLimit: String {
        NumberFormatter.formatValue(card.limit, currency: .ARS, options: [.showCurrencySymbol])
    }
}
```

Pass component ViewModels inline at the call site:

```swift
CardListItemView(viewModel: .init(card: card))
```

### Navigation goes through the delegate

Views never navigate directly. They call through the ViewModel's delegate:

```swift
.onTapGesture {
    viewModel.delegate?.navigateToDetail(card: card)
}
```

---

## Design System Usage

### Typography — always use `Fonts`

```swift
// ✅
.font(Fonts.bold(size: 36))
.font(Fonts.medium(size: 21))
.font(Fonts.regular(size: 14))

// ❌ Never use system fonts directly
.font(.system(size: 21, weight: .medium))
```

### Colors — always use `Palette`

```swift
// ✅
.foregroundColor(Palette.grayUltraDark.swiftUI)
.background(Palette.primary.swiftUI.opacity(0.4))

// ❌
.foregroundColor(.gray)
.background(Color.blue.opacity(0.4))
```

Use `Material` for blur/frosted backgrounds:
```swift
.background(Material.ultraThin)   // nav bars
.background(Material.regular)     // cards
.background(Material.thin)        // overlays
```

### Custom modifiers

```swift
// Loading skeleton — redacts content while loading
.isSkeletonView(viewModel.isLoading)

// Hide a view without removing it from layout
.isHidden(viewModel.shouldHideCard)

// Screen entry transition
.transitionStyle(.push)
```

### Modifier order convention

Apply modifiers in this order: interaction → spacing → background → shape → shadow

```swift
CardListItemView(viewModel: .init(card: card))
    .onTapGesture { ... }                           // 1. Interaction
    .padding(16)                                     // 2. Spacing
    .background(Material.regular)                    // 3. Background
    .clipShape(RoundedRectangle(cornerRadius: 16))   // 4. Shape
    .shadow(color: Palette.staticBlack.swiftUI.opacity(0.1), radius: 8, x: 0, y: 2) // 5. Shadow
```

---

## Previews

Wrap all preview code in `#if DEBUG`. Register mock repositories via `Container.shared` so previews don't hit real services:

```swift
#if DEBUG
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = ListViewModel()
        let _ = Container.shared.cardsRepository.register { MockCardsRepository() }
        return ListView(viewModel: vm)
    }
}

private final class MockCardsRepository: CardsRepositoryProtocol {
    func fetchCards() async -> Result<[Card], ServerError> {
        .success([.mock(), .mock(color: .PURPLE)])
    }
}
#endif
```

For components, use `.previewLayout(.sizeThatFits)`:

```swift
struct CardListItemView_Previews: PreviewProvider {
    static var previews: some View {
        CardListItemView(viewModel: .init(card: .mock()))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
```

---

## Localization

Never hardcode strings in Views. Use the module's `Strings` enum:

```swift
// ✅
Text(CardsListStrings.Card.List.title)

// ❌
Text("My Cards")
```

String enum structure:
```swift
enum FeatureStrings {
    enum SectionName {
        static let title = NSLocalizedString("feature.section.title", bundle: .main, comment: "")
        static func subtitle(_ count: Int) -> String {
            String(format: NSLocalizedString("feature.section.subtitle", bundle: .main, comment: ""), count)
        }
    }
}
```

---

## Quick Checklist

- [ ] Body delegates to `@ViewBuilder` computed properties — no inline complexity
- [ ] Each section has a `// MARK:` comment
- [ ] `@ObservedObject` (not `@StateObject`) for the ViewModel
- [ ] Data loaded with `.task { await }`
- [ ] Navigation goes through `viewModel.delegate?`
- [ ] All fonts via `Fonts.*`, all colors via `Palette.*`
- [ ] Loading state uses `.isSkeletonView(viewModel.isLoading)`
- [ ] Strings come from a `Strings` enum — no hardcoded text
- [ ] Previews are inside `#if DEBUG` with mock repositories
