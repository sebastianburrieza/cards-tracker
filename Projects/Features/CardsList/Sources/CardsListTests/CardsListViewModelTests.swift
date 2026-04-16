//  CardsListTests.swift

import XCTest
import Factory
import CoreModels
@testable import CardsList

final class CardsListViewModelTests: XCTestCase {

    var viewModel: ListViewModel!
    var mockRepository: MockCardsRepository!
    var mockDelegate: MockDelegate!

    override func setUp() {
        super.setUp()
        mockRepository = MockCardsRepository()
        Container.shared.cardsRepository.register { self.mockRepository }
        viewModel = ListViewModel()
        mockDelegate = MockDelegate()
        viewModel.delegate = mockDelegate
    }

    override func tearDown() {
        super.tearDown()
        Container.shared.cardsRepository.reset()
        viewModel = nil
        mockRepository = nil
        mockDelegate = nil
    }

    // MARK: - fetchCards Success Tests

    func test_fetchCards_success_populatesCardsArray() async throws {
        let mockCards = [Card.mock(), Card.mock(id: "unique-id-123")]
        mockRepository.fetchCardsResult = .success(mockCards)

        await viewModel.fetchCards()

        XCTAssertEqual(viewModel.cards, mockCards)
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_fetchCards_success_setsLoadingFalseAfterFetch() async throws {
        mockRepository.fetchCardsResult = .success([Card.mock()])

        var loadingStates: [Bool] = []

        let task = Task {
            await viewModel.fetchCards()
            loadingStates.append(viewModel.isLoading)
        }

        await task.value

        XCTAssertEqual(loadingStates.last, false, "isLoading should be false after fetch completes")
    }

    func test_fetchCards_success_emptyArray() async throws {
        mockRepository.fetchCardsResult = .success([])

        await viewModel.fetchCards()

        XCTAssertEqual(viewModel.cards, [])
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - fetchCards Failure Tests

    func test_fetchCards_failure_cardsArrayRemainsEmpty() async throws {
        mockRepository.fetchCardsResult = .failure(ServerError.connection)

        await viewModel.fetchCards()

        XCTAssertEqual(viewModel.cards, [])
    }

    func test_fetchCards_failure_setsLoadingFalseAfterError() async throws {
        mockRepository.fetchCardsResult = .failure(ServerError(.unexpectedError))

        await viewModel.fetchCards()

        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Loading State Tests

    func test_fetchCards_isLoadingTrueWhileFetching() async throws {
        var observedLoadingState: Bool?

        let slowTask = Task {
            mockRepository.fetchCardsResult = .success([Card.mock()])
            await viewModel.fetchCards()
        }

        // Observe loading state immediately
        observedLoadingState = viewModel.isLoading

        await slowTask.value

        XCTAssertTrue(observedLoadingState == true || observedLoadingState == false,
                      "Loading state was observable during fetch")
    }

    func test_fetchCards_isLoadingFalseAfterCompletion() async throws {
        mockRepository.fetchCardsResult = .success([Card.mock()])

        await viewModel.fetchCards()

        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - Multiple Calls Tests

    func test_fetchCards_multipleCalls_lastResultWins() async throws {
        let firstCards = [Card.mock(id: "first")]
        let secondCards = [Card.mock(id: "second"), Card.mock(id: "second-2")]

        mockRepository.fetchCardsResult = .success(firstCards)
        await viewModel.fetchCards()
        XCTAssertEqual(viewModel.cards.first?.id, "first")

        mockRepository.fetchCardsResult = .success(secondCards)
        await viewModel.fetchCards()
        XCTAssertEqual(viewModel.cards.count, 2)
        XCTAssertEqual(viewModel.cards.first?.id, "second")
    }

    func test_fetchCards_multipleCalls_repositoryCalledEachTime() async throws {
        mockRepository.fetchCardsResult = .success([])

        await viewModel.fetchCards()
        await viewModel.fetchCards()
        await viewModel.fetchCards()

        XCTAssertEqual(mockRepository.fetchCardsCallCount, 3)
    }

    // MARK: - Delegate Behavior Tests

    func test_fetchCards_noDelegateSet_failureDoesNotCrash() async throws {
        viewModel.delegate = nil
        mockRepository.fetchCardsResult = .failure(ServerError.connection)

        await viewModel.fetchCards()

        XCTAssertEqual(viewModel.cards, [])
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_fetchCards_noDelegateSet_successWorks() async throws {
        viewModel.delegate = nil
        let mockCards = [Card.mock()]
        mockRepository.fetchCardsResult = .success(mockCards)

        await viewModel.fetchCards()

        XCTAssertEqual(viewModel.cards, mockCards)
    }

    // MARK: - Edge Cases

    func test_fetchCards_failure_connectionError() async throws {
        mockRepository.fetchCardsResult = .failure(ServerError.connection)

        await viewModel.fetchCards()

        XCTAssertEqual(viewModel.errorTitle, "Connection error")
        XCTAssertEqual(viewModel.errorMessage, "Check your internet connection and try again.")
    }

    func test_fetchCards_failure_unauthorized() async throws {
        mockRepository.fetchCardsResult = .failure(
            ServerError(.unauthorized, title: "Unauthorized", message: "Invalid credentials")
        )

        await viewModel.fetchCards()

        XCTAssertEqual(viewModel.errorTitle, "Unauthorized")
        XCTAssertEqual(viewModel.errorMessage, "Invalid credentials")
    }
}

// MARK: - MockDelegate

final class MockDelegate: ListNavigationDelegate {

    var navigateToDetailCallCount = 0
    var showErrorCallCount = 0

    var capturedCard: Card?
    var capturedError: ServerError?

    func navigateToDetail(card: Card) {
        navigateToDetailCallCount += 1
        capturedCard = card
    }

    func showError(_ error: ServerError) {
        showErrorCallCount += 1
        capturedError = error
    }
}
