//  TransactionsDataSource.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import Foundation

enum TransactionsDataState {
    case failure
    case noData
    case hasData([TransactionItemViewModel])
}

final class TransactionsDataSource {

    var rows: [TransactionItemViewModel] = []
    var nextPageCursor: String = ""
    var isLastPage: Bool = false

    var isEmpty: Bool {
        rows.isEmpty
    }

    func shouldFetchNextPage(_ index: Int) -> Bool {
        index == rows.count - 3 && !nextPageCursor.isEmpty
    }
    
    func update(with data: TransactionsPage) {
        nextPageCursor = data.cursor ?? ""
        isLastPage = nextPageCursor.isEmpty
        rows.append(contentsOf: data.results.map(TransactionItemViewModel.init(transaction:)))
    }
    
    func reset() {
        rows.removeAll()
        nextPageCursor = ""
    }
}
