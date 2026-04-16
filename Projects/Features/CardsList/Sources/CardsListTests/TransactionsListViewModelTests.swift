//  TransactionsListViewModelTests.swift

import XCTest
import Factory
import CoreModels
@testable import CardsList

final class TransactionsListViewModelTests: XCTestCase {

    var viewModel: TransactionsListViewModel!
    var mockRepository: MockCardsRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockCardsRepository()
        Container.shared.cardsRepository.register { self.mockRepository }
        viewModel = TransactionsListViewModel(cardId: "card-123")
    }

    override func tearDown() {
        super.tearDown()
        Container.shared.cardsRepository.reset()
        viewModel = nil
        mockRepository = nil
    }

    // MARK: - fetchData Success

    func test_fetchData_success_withTransactions_setsHasDataState() async {
        let transactions = [
            Transaction.mock(id: "tx-1", cardId: "card-123"),
            Transaction.mock(id: "tx-2", cardId: "card-123")
        ]
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: nil, results: transactions, totalAmount: 100, totalTransactions: 2)
        )

        await viewModel.fetchData()

        guard case .hasData(let items) = viewModel.viewState else {
            return XCTFail("Expected .hasData, got \(viewModel.viewState)")
        }
        XCTAssertEqual(items.count, 2)
        XCTAssertFalse(viewModel.isLoading)
    }

    func test_fetchData_success_withEmptyResults_setsNoDataState() async {
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: nil, results: [], totalAmount: 0, totalTransactions: 0)
        )

        await viewModel.fetchData()

        guard case .noData = viewModel.viewState else {
            return XCTFail("Expected .noData, got \(viewModel.viewState)")
        }
        XCTAssertFalse(viewModel.isLoading)
    }

    // MARK: - fetchData Failure

    func test_fetchData_failure_setsFailureState() async {
        mockRepository.fetchTransactionsResult = .failure(.connection)

        await viewModel.fetchData()

        guard case .failure = viewModel.viewState else {
            return XCTFail("Expected .failure, got \(viewModel.viewState)")
        }
    }

    func test_fetchData_failure_setsLoadingAndFetchingFalse() async {
        mockRepository.fetchTransactionsResult = .failure(.unexpected)

        await viewModel.fetchData()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isFetching)
    }

    // MARK: - Repository Interaction

    func test_fetchData_callsRepositoryOnce() async {
        await viewModel.fetchData()

        XCTAssertEqual(mockRepository.fetchTransactionsCallCount, 1)
    }

    func test_fetchData_passesCorrectCardId() async {
        await viewModel.fetchData()

        XCTAssertEqual(mockRepository.capturedCardIds.first, "card-123")
    }

    func test_fetchData_withNilCardId_doesNotCaptureCardId() async {
        viewModel = TransactionsListViewModel(cardId: nil)

        await viewModel.fetchData()

        XCTAssertTrue(mockRepository.capturedCardIds.isEmpty)
    }

    // MARK: - Pagination: fetchNextPage

    func test_fetchNextPage_whenCursorIsEmpty_doesNotFetch() async {
        // First page has no cursor → last page
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: nil, results: [Transaction.mock()], totalAmount: 10, totalTransactions: 1)
        )
        await viewModel.fetchData()
        mockRepository.fetchTransactionsCallCount = 0

        await viewModel.fetchNextPage(index: 0)

        XCTAssertEqual(mockRepository.fetchTransactionsCallCount, 0)
    }

    func test_fetchNextPage_atTriggerIndex_fetchesNextPage() async {
        // Load first page: 20 rows, cursor "20" means more data available
        let firstPage = (0..<20).map { Transaction.mock(id: "tx-\($0)", cardId: "card-123") }
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: "20", results: firstPage, totalAmount: 0, totalTransactions: 40)
        )
        await viewModel.fetchData()

        // Trigger index = rows.count - 3 = 17
        await viewModel.fetchNextPage(index: 17)

        XCTAssertEqual(mockRepository.fetchTransactionsCallCount, 2)
    }

    func test_fetchNextPage_atNonTriggerIndex_doesNotFetch() async {
        let firstPage = (0..<20).map { Transaction.mock(id: "tx-\($0)", cardId: "card-123") }
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: "20", results: firstPage, totalAmount: 0, totalTransactions: 40)
        )
        await viewModel.fetchData()

        await viewModel.fetchNextPage(index: 5)

        XCTAssertEqual(mockRepository.fetchTransactionsCallCount, 1)
    }

    func test_fetchNextPage_appendsRowsToExistingOnes() async {
        let firstPage = (0..<20).map { Transaction.mock(id: "tx-\($0)", cardId: "card-123") }
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: "20", results: firstPage, totalAmount: 0, totalTransactions: 25)
        )
        await viewModel.fetchData()

        let secondPage = (20..<25).map { Transaction.mock(id: "tx-\($0)", cardId: "card-123") }
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: nil, results: secondPage, totalAmount: 0, totalTransactions: 25)
        )
        await viewModel.fetchNextPage(index: 17)

        guard case .hasData(let items) = viewModel.viewState else {
            return XCTFail("Expected .hasData")
        }
        XCTAssertEqual(items.count, 25)
    }

    // MARK: - isLastPage

    func test_isLastPage_whileLoading_returnsFalse() {
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(viewModel.isLastPage)
    }

    func test_isLastPage_whenNoCursorReturned_returnsTrue() async {
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: nil, results: [Transaction.mock()], totalAmount: 10, totalTransactions: 1)
        )

        await viewModel.fetchData()

        XCTAssertTrue(viewModel.isLastPage)
    }

    func test_isLastPage_whenCursorPresent_returnsFalse() async {
        let transactions = (0..<20).map { Transaction.mock(id: "tx-\($0)", cardId: "card-123") }
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: "20", results: transactions, totalAmount: 0, totalTransactions: 40)
        )

        await viewModel.fetchData()

        XCTAssertFalse(viewModel.isLastPage)
    }

    // MARK: - resetTransactions

    func test_resetTransactions_setsLoadingTrue() async {
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: nil, results: [Transaction.mock()], totalAmount: 10, totalTransactions: 1)
        )
        await viewModel.fetchData()
        XCTAssertFalse(viewModel.isLoading)

        viewModel.resetTransactions()

        XCTAssertTrue(viewModel.isLoading)
    }

    func test_resetTransactions_setsPlaceholderState() async {
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: nil, results: [Transaction.mock()], totalAmount: 10, totalTransactions: 1)
        )
        await viewModel.fetchData()

        viewModel.resetTransactions()

        guard case .hasData(let items) = viewModel.viewState else {
            return XCTFail("Expected .hasData with placeholder after reset")
        }
        XCTAssertEqual(items.count, 7) // TransactionItemViewModel.placeHolder produces 7 items
    }

    func test_resetTransactions_clearsRowsSoNextFetchStartsFromBeginning() async {
        let firstPage = (0..<20).map { Transaction.mock(id: "tx-\($0)", cardId: "card-123") }
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: "20", results: firstPage, totalAmount: 0, totalTransactions: 40)
        )
        await viewModel.fetchData()

        viewModel.resetTransactions()

        let freshPage = [Transaction.mock(id: "fresh-tx", cardId: "card-123")]
        mockRepository.fetchTransactionsResult = .success(
            TransactionsPage(cursor: nil, results: freshPage, totalAmount: 10, totalTransactions: 1)
        )
        await viewModel.fetchData()

        guard case .hasData(let items) = viewModel.viewState else {
            return XCTFail("Expected .hasData")
        }
        // After reset, rows start fresh — no accumulation from the previous page
        XCTAssertEqual(items.count, 1)
    }
}
