//  ListView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Utilities
import ComponentsUI
import ResourcesUI
import Factory
import CoreModels

struct ListView: View {

    @State var viewModel: ListViewModel

    var body: some View {
        ZStack {
            Palette.backgroundMedium.swiftUI
                .ignoresSafeArea()

            VStack(spacing: 0) {
                cardList
            }
        }
        .refreshable {
            await viewModel.fetchCards()
        }
        .safeAreaInset(edge: .top) {
            headerView
                .background(Palette.primary.swiftUI
                    .ignoresSafeArea(edges: .top)
                    .shadow(color: Palette.staticBlack.swiftUI.opacity(0.3), radius: 8, x: 0, y: 3)
                )
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
            titleRow
            summaryCard
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
    }

    @ViewBuilder
    private var titleRow: some View {
        HStack {
            Text("CARDLIST_TITLE".localized)
                .font(Fonts.bold(size: 32))
                .foregroundColor(Palette.backgroundLight.swiftUI)

            Spacer()

            Button(action: { viewModel.navigateToAddCard()
            }, label: {
                Image(systemName: "plus")
                    .font(Fonts.bold(size: 20))
                    .foregroundColor(Palette.backgroundLight.swiftUI)
                    .padding(8)
                    .background(
                        Circle()
                            .stroke(Palette.backgroundLight.swiftUI.opacity(0.5), lineWidth: 1.5)
                    )
            })
        }
    }

    @ViewBuilder
    private var summaryCard: some View {
        VStack(spacing: 4) {
            Text("CARDLIST_TOTAL_CONSUMED".localized)
                .font(Fonts.regular(size: 18))
                .foregroundColor(Palette.backgroundLight.swiftUI.opacity(0.7))

            BouncingAmount(value: $viewModel.totalConsumed,
                           font: Fonts.bold(size: 32),
                           fontColor: $viewModel.fontColor,
                           currency: Currency.ARS)

            HStack {
                Text("CARDLIST_AVAILABLE".localized + " ")
                    .font(Fonts.regular(size: 18))
                    .foregroundColor(Palette.backgroundLight.swiftUI.opacity(0.7))
                
                BouncingAmount(value: $viewModel.totalAvailable,
                               font: Fonts.medium(size: 18),
                               fontColor: $viewModel.fontColor,
                               currency: Currency.ARS)
            }
        }
        .frame(maxWidth: .infinity)
        .isSkeletonView(viewModel.isLoading)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Palette.backgroundLight.swiftUI.opacity(0.1))
        )
    }

    // MARK: Card list

    @ViewBuilder
    private var cardList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 16) {
                ForEachAnimation(viewModel.cards) { card in
                    CardListItemView(viewModel: .init(card: card))
                        .isSkeletonView(viewModel.isLoading)
                        .onTapGesture {
                            viewModel.delegate?.navigateToDetail(card: card)
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
