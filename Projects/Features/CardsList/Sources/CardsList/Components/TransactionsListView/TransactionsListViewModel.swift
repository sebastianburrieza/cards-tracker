//  TransactionsListViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory
import CoreModels
import ResourcesUI
import ComponentsUI

@Observable
final class TransactionsListViewModel {
    
    @ObservationIgnored
    @Injected(\.cardsRepository) private var repository
    
    var isLoading: Bool = true
    var isFetching: Bool = false
    
    var viewState: TransactionsDataState = .hasData(TransactionItemViewModel.placeHolder)
    var activeFilter: TransactionFilter = .all
    private var listDataSource = TransactionsDataSource()

    var filteredViewState: TransactionsDataState {
        guard case .hasData(let items) = viewState else { return viewState }
        let filtered: [TransactionItemViewModel]
        switch activeFilter {
        case .all:
            filtered = items
        case .installments:
            filtered = items.filter { $0.transaction.installment != nil }
        case .dollars:
            filtered = items.filter { $0.transaction.currency == .USD }
        }
        return filtered.isEmpty ? .noData : .hasData(filtered)
    }
    
    var cardId: String?
    
    var onDidAppear: Bool = false
    
    init(cardId: String?) {
        self.cardId = cardId
    }
    
    convenience init() {
        self.init(cardId: nil)
    }
    
    func fetchData() async {
        await MainActor.run { isLoading = true }
        await fetchTransactions()
    }

    func fetchNextPage(index: Int) async {
        guard !isFetching, listDataSource.shouldFetchNextPage(index) else { return }

        await fetchTransactions()
    }

    private func fetchTransactions() async {
        await MainActor.run { isFetching = true }
        
        let result = await repository.fetchTransactions(cursor: listDataSource.nextPageCursor, cardId: cardId, pageSize: 20)
        
        await MainActor.run {
            switch result {
            case .success(let page):
                listDataSource.update(with: page)
                withAnimation(.smooth(duration: 0.4, extraBounce: 0.2)) {
                    viewState = listDataSource.isEmpty ? .noData : .hasData(listDataSource.rows)
                    isLoading = false
                }
            case .failure:
                withAnimation(.smooth(duration: 0.4)) {
                    viewState = .failure
                    isLoading = false
                }
            }
            isFetching = false
        }
    }
    
    var isLastPage: Bool {
        guard !isLoading else { return false }
        return listDataSource.isLastPage
    }
    
    func resetTransactions() {
        withAnimation(.smooth(duration: 0.3)) {
            listDataSource.reset()
            viewState = .hasData(TransactionItemViewModel.placeHolder)
            isLoading = true
        }
    }
    
}
