---
name: ios-testing-pattern
description: Use when writing unit tests, create mocks, using @Injected, test doubles, or deciding between real implementations vs mocks. Triggers: unit test, mock, fake, stub, XCTestCase, XCTAssert, test double, @Injected test, test setup, setUp, tearDown, async test, ViewModel test, service test. Use this skill whenever the user wants to write, modify, or understand tests - even if they just say 'add tests for this'.
---

# iOS Testing Patterns

Guidelines for writing effective unit tests in the iOS project.

## Two Testing Frameworks

The project uses **two** testing frameworks. Both are valid — use whichever matches the module's existing tests:

### Swift Testing (newer modules — preferred for new tests)

```swift
import Testing
import Foundation
@testable import CardsList

@Suite("CardDetailViewModelTests", .serialized)
@MainActor
struct CardDetailViewModelTests {

    func createViewModel(repository: CardRepositoryMock? = nil) -> CardDetailViewModel {
        let mockRepository = repository ?? CardRepositoryMock()
        return CardDetailViewModel(repository: mockRepository)
    }

    @Test("getInitialConfig with subscribed status sets state correctly")
    func testGetInitialConfigSubscribed() async {
        let mockRepository = CardRepositoryMock()
        mockRepository.settingsToReturn = Card.makeSettings(status: .subscribed)
        mockRepository.cardsToReturn = []

        let viewModel = createViewModel(repository: mockRepository)
        await viewModel.getInitialConfig()

        #expect(viewModel.state == .subscribed)
        #expect(viewModel.cards.isEmpty)
    }

    @Test("getInitialConfig with cards sets state to cards")
    func testGetInitialConfigWithCards() async {
        let mockRepository = CardRepositoryMock()
        mockRepository.cardsToReturn = [Card.mock()]

        let viewModel = createViewModel(repository: mockRepository)
        await viewModel.getInitialConfig()

        #expect(viewModel.state == .cards)
    }
}
```

**Key differences from XCTest:**
- `@Suite` + `struct` instead of `class: XCTestCase`
- `@Test("description")` instead of `func testXxx()`
- `#expect(condition)` instead of `XCTAssertTrue/Equal/etc.`
- `.serialized` trait when tests share state
- No `setUp`/`tearDown` — use factory methods instead

### XCTest

```swift
import XCTest
import Factory
@testable import CardsList

@MainActor final class CardDetailViewModelTests: XCTestCase {
    var viewModel: CardDetailViewModel!
    var delegate = CardDetailNavigationDelegateMock()
    var repository: CardMockRepository!

    func test_fetch_cards_with_no_error() async {
        repository = CardMockRepository()
        viewModel = CardDetailViewModel()
        viewModel.delegate = delegate

        _ = await viewModel.fetchCards()

        XCTAssertFalse(viewModel.cards.isEmpty)
        XCTAssertFalse(viewModel.shouldLoadEmptyState)
    }
}
```

## Repository Mock Pattern

Each module creates its own mocks locally (no centralized mock module). The standard pattern tracks call counts and configurable return values:

```swift
final class CardRepositoryMock: CardRepositoryProtocol {

    // MARK: - fetchCards
    var error: ServerError?
    var cards: [Card] = [.mock()]
    var fetchCardsCallCount = 0

    func fetchCards() async -> Result<[Card], ServerError> {
        fetchCardsCallCount += 1
        if let error {
            return .failure(error)
        }
        return .success(cards)
    }
}
```

## Test Data Factory Pattern

Use `.mock()` static methods on models to create test data with sensible defaults:

```swift
extension Card {
    static func mock(
        id: String = "1",
        holderName: String = "Juan",
        color: ColorCode = .ORANGE,
        limit: Int = 1000000,
        available: Int = 1000
    ) -> Card {
        Card(id: id, holderName: holderName, color: color, limit: limit, available: available)
    }
}
```

## Navigation Delegate Mocks

For ViewModels that use delegate-based navigation, create minimal mocks:

```swift
final class CardsListNavigationDelegateMock: CardsListNavigationDelegate {
    func navigateBack() {}
    func navigateToDetail(with card: Card) {}
    func showError(_ error: ServerError) {}
}
```

## makeSUT Pattern

Use a `makeSUT` (System Under Test) factory method to reduce boilerplate:

```swift
private func makeSUT(
    card: Card = .mock(),
    userId: String = "user-1"
) -> CardDetailViewModel {
        CardDetailViewModel(card: card, userId: userId)
}
```

## Async Testing Patterns

### Direct async test methods

```swift
// XCTest
func test_confirmPurchase_success() async {
    repository.createdTransaction = .mock(id: .mock(id: "abc"))
    let result = await makeSUT().confirmPurchase()

    switch result {
    case .success(let transaction):
        XCTAssertEqual(transaction?.id, "abc")
    case .failed:
        XCTFail("Expected success")
    }
}

// Swift Testing
@Test("confirmPurchase failure returns error")
func testConfirmPurchaseFailure() async {
    let error = ServerError(code: "CARD_NOT_FOUND", title: "Error", message: "Not found")
    repository.createTransactionError = error

    let result = await makeSUT().confirmPurchase()

    if case .failed(let err) = result {
        #expect(err.code == "CARD_NOT_FOUND")
    } else {
        Issue.record("Expected failure")
    }
}
```

### Testing that ViewModel calls repository correctly


```swift
func test_confirmPurchase_callsServiceWithCorrectCardId() async {
    let card = Card.mock(id: "abc-xyz")
    let sut = makeSUT(card: card)
    repository.createdTransaction = .mock()

    _ = await sut.confirmPurchase()

    XCTAssertEqual(repository.lastCreatedCardId, "abc-xyz")
    XCTAssertEqual(repository.createSubscriptionCallCount, 1)
}
```

### Conform to protocol to replace the live implementation with a mock in unit tests

```swift
    Container.shared.cardsRepository.register { MockCardsRepository() }
```

## Test File Structure

```
Sources/[Feature]Tests/
├── [Feature]ViewModelTests.swift      # ViewModel tests
├── [Feature]RepositoryTests.swift     # Repository tests
└── Mocks/
    ├── [Feature]RepositoryMock.swift     # Repository mock
    ├── [Feature]NavigationMock.swift   # Delegate mock
    └── [Model]+Mock.swift            # Test data factories
```

## Checklist

- [ ] Test file uses same framework as existing module tests (XCTest or Swift Testing)
- [ ] Mocks track call counts and capture parameters
- [ ] Test data uses `.mock()` factory methods
- [ ] `@MainActor` on test class/struct when testing ViewModels
- [ ] Async tests use `async` directly (no `waitForExpectations`)
- [ ] Tests verify both success and failure paths
- [ ] No real network calls — all services are mocked
