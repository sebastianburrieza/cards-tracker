//  CardDetailView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory
import ResourcesUI
import ComponentsUI
import Utilities
import CoreModels

struct CardDetailView: View {

    @State var viewModel: CardDetailViewModel

    var body: some View {
        ZStack {
            Palette.backgroundMedium.swiftUI
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    FilterPillsView(selectedFilter: $viewModel.selectedFilter)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                    transactionsListView
                }
            }
        }
        .safeAreaInset(edge: .top) {
            headerView
        }
        .onChange(of: viewModel.selectedFilter) { _, newFilter in
            transactionsListViewModel.activeFilter = newFilter
        }
        .toastErrorView(title: viewModel.errorTitle ?? "",
                        message: viewModel.errorMessage,
                        duration: 3,
                        isPresented: $viewModel.isError)
    }

    // MARK: Header

    @ViewBuilder
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            navigationBarView
            summaryCard
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 12)
        .background(
            Palette.blue.swiftUI
                .ignoresSafeArea(edges: .top)
                .shadow(color: Palette.staticBlack.swiftUI.opacity(0.3), radius: 8, x: 0, y: 3)
        )
    }

    @ViewBuilder
    private var navigationBarView: some View {
        NavigationBarView(
            leftView: LeftButtonView(type: .back, action: {
                viewModel.delegate?.navigateToPrevious()
            }),
            middleView:
                VStack(alignment: .center, spacing: 4) {
                    HStack(spacing: 0) {
                        Text(viewModel.card.bankName)
                            .font(Fonts.regular(size: 21))
                            .foregroundColor(Palette.backgroundLight.swiftUI)
                        
                        Text(viewModel.formattedLastFourDigits)
                            .font(Fonts.regular(size: 21))
                            .foregroundColor(Palette.backgroundMedium.swiftUI)
                    }
                    Text(viewModel.typeLabel)
                        .font(Fonts.regular(size: 15))
                        .foregroundColor(Palette.backgroundLight.swiftUI)
                }
            , rightView:
                Button(action: { viewModel.navigateToSettings() }
                , label: {
                    Image(systemName: "gearshape.fill")
                        .font(Fonts.medium(size: 18))
                        .foregroundColor(Palette.backgroundLight.swiftUI)
                        .padding(8)
                        .background(
                            Circle()
                                .stroke(Palette.backgroundLight.swiftUI.opacity(0.5), lineWidth: 1.5)
                        )
                })
        )
    }

    @ViewBuilder
    private var summaryCard: some View {
        VStack(spacing: 4) {
            Text("DETAIL_TITLE".localized)
                .font(Fonts.regular(size: 18))
                .foregroundColor(Palette.backgroundLight.swiftUI.opacity(0.7))

            Text(viewModel.formattedAmountUsed)
                .font(Fonts.bold(size: 32))
                .foregroundColor(Palette.backgroundLight.swiftUI)

            (Text("CARDLIST_AVAILABLE".localized + " ")
                .font(Fonts.regular(size: 18))
                .foregroundColor(Palette.backgroundLight.swiftUI.opacity(0.7))
            + Text(viewModel.formattedAvailable)
                .font(Fonts.medium(size: 18))
                .foregroundColor(Palette.backgroundLight.swiftUI))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Palette.backgroundLight.swiftUI.opacity(0.1))
        )
    }

    // MARK: Transactions list

    @State private var transactionsListViewModel = TransactionsListViewModel()

    @ViewBuilder
    private var transactionsListView: some View {
        VStack {
            TransactionsListView(viewModel: transactionsListViewModel, transactionTapped: { transaction in
                viewModel.delegate?.navigateToTransactionDetail(id: transaction.id)
            })
            .onAppear {
                transactionsListViewModel.cardId = viewModel.card.id
            }
        }
    }
}
