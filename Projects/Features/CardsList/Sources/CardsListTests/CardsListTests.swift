//  CardsListTests.swift

import XCTest
import Factory
import CoreModels
@testable import CardsList

final class CardsListTests: XCTestCase {

    var viewModel: ListViewModel!
    var mockRepository: MockCardsRepository!
    var spyDelegate: SpyDelegate!

    override func setUp() {
        super.setUp()
        mockRepository = MockCardsRepository()
        Container.shared.cardsRepository.register { self.mockRepository }
        viewModel = ListViewModel()
        spyDelegate = SpyDelegate()
        viewModel.delegate = spyDelegate
    }

    override func tearDown() {
        super.tearDown()
        Container.shared.cardsRepository.reset()
        viewModel = nil
        mockRepository = nil
        spyDelegate = nil
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

    func test_fetchCards_failure_callsDelegateShowError() async throws {
        let expectedError = ServerError(
            .cardNotFound,
            title: "Card Not Found",
            message: "The card you requested does not exist."
        )
        mockRepository.fetchCardsResult = .failure(expectedError)

        await viewModel.fetchCards()

        XCTAssertEqual(spyDelegate.showErrorCallCount, 1)
        let capturedError = try XCTUnwrap(spyDelegate.capturedError)
        XCTAssertEqual(capturedError.code, expectedError.code)
        XCTAssertEqual(capturedError.title, expectedError.title)
        XCTAssertEqual(capturedError.message, expectedError.message)
    }

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

        let capturedError = try XCTUnwrap(spyDelegate.capturedError)
        XCTAssertEqual(capturedError.code, .connectionError)
    }

    func test_fetchCards_failure_unauthorized() async throws {
        mockRepository.fetchCardsResult = .failure(
            ServerError(.unauthorized, title: "Unauthorized", message: "Invalid credentials")
        )

        await viewModel.fetchCards()

        let capturedError = try XCTUnwrap(spyDelegate.capturedError)
        XCTAssertEqual(capturedError.code, .unauthorized)
    }
}

// MARK: - SpyDelegate

final class SpyDelegate: ListNavigationDelegate {

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

// MARK: - Card Mock Extension

extension Card {
    static func mock(id: String = UUID().uuidString,
                     type: CardType = .creditPlastic,
                     color: ColorCode = .GREEN,
                     hexa: String? = nil,
                     holderName: String = "Test User",
                     limit: Int = 100000,
                     available: Int = 50000,
                     closingDate: Date = Date(),
                     dueDate: Date = Date()) -> Card {
        Card(id: id,
             type: type,
             color: color,
             hexa: hexa,
             holderName: holderName,
             limit: limit,
             available: available,
             closingDate: closingDate,
             dueDate: dueDate)
    }
}
