//  TransactionsListView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import CoreModels
import ResourcesUI
import ComponentsUI

struct TransactionsListView: View {
    
    @State var viewModel: TransactionsListViewModel

    var transactionTapped: (_ transaction: CoreModels.Transaction) -> Void
    
    var body: some View {
        
        VStack {
            switch viewModel.filteredViewState {
            case .failure:
                FailureTransactionsView()
                
            case .noData:
                NoTransactionsView()
                
            case .hasData(let items):
                transactionsView(items)

            }
        }
        .background(Material.regular)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Palette.staticBlack.swiftUI.opacity(0.1), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16)
        .onAppear {
            viewModel.resetTransactions()
            Task {
                await viewModel.fetchData()
            }
        }
    }
    
    @ViewBuilder
    private func transactionsView(_ items: [TransactionItemViewModel]) -> some View {
        // LazyVStack: only renders transaction rows that are currently visible.
        LazyVStack {
            ForEach(Array(items.enumerated()), id: \.element.transaction.id) { index, item in
                TransactionItemView(viewModel: item, onTapped: { transaction in
                    transactionTapped(transaction) })
                .frame(height: 50)
                .padding(.horizontal, 5)
                .transition(.opacity)
                .onAppear {
                    Task {
                        await viewModel.fetchNextPage(index: index)
                    }
                }
                .isSkeletonView(viewModel.isLoading)

                if index < items.count - 1 {
                    Divider()
                }
            }
        }
    }
}
