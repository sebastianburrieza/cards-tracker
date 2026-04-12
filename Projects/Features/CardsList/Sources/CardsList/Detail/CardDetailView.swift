//  CardDetailView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import Factory
import ResourcesUI
import ComponentsUI
import Utilities

struct CardDetailView: View {

    @ObservedObject var viewModel: CardDetailViewModel

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            VStack(spacing: 0) {

                transactionsList
                    .padding(.top, 20)
            }
        }
        .safeAreaInset(edge: .top) {
            VStack {
                navigationBarView

                headerSection
                    .padding(.horizontal, 16)

                actionButtons
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
            }
            .background(Material.thin)
        }
        .task { await viewModel.fetchTransactions() }
    }

    // MARK: Background

    @ViewBuilder
    private var background: some View {
        LinearGradient(
            colors: [
                Palette.primary.swiftUI.opacity(0.4),
                Palette.orange.swiftUI.opacity(0.2)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: NavigationBar

    @ViewBuilder
    private var navigationBarView: some View {
        NavigationBarView(
            leftView: LeftButtonView(type: .back, action: {
                viewModel.delegate?.navigateToPrevious()
            }),
            middleView: Text(viewModel.card.holderName)
                .font(Fonts.medium(size: 18))
                .foregroundColor(Palette.grayUltraDark.swiftUI),
            rightView: CardView(
                type: viewModel.card.type,
                color: viewModel.card.color,
                hexa: viewModel.card.hexa,
                size: 36,
                isShadow: false
            )
        )
    }

    // MARK: Header

    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text(CardsListStrings.Card.Detail.consumos)
                .font(Fonts.regular(size: 14))
                .foregroundColor(Palette.grayMedium.swiftUI)

            Text(viewModel.formattedAmountUsed)
                .font(Fonts.bold(size: 36))
                .foregroundColor(Palette.grayUltraDark.swiftUI)

            Text(viewModel.formattedRemaining)
                .font(Fonts.regular(size: 14))
                .foregroundColor(Palette.grayMedium.swiftUI)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Action buttons

    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: {
                Haptic.selection()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "pause.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text(CardsListStrings.Card.Detail.pausar)
                        .font(Fonts.medium(size: 16))
                }
                .foregroundColor(Palette.staticWhite.swiftUI)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Palette.green.swiftUI)
                .clipShape(Capsule())
            }

            Button(action: {
                Haptic.selection()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text(CardsListStrings.Card.Detail.reportar)
                        .font(Fonts.medium(size: 16))
                }
                .foregroundColor(Palette.staticWhite.swiftUI)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Palette.orange.swiftUI)
                .clipShape(Capsule())
            }
        }
    }

    // MARK: Transactions list

    @ViewBuilder
    private var transactionsList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(Array(viewModel.transactions.enumerated()), id: \.element.id) { index, transaction in
                    TransactionItemView(viewModel: .init(transaction: transaction))
                        .onTapGesture {
                            viewModel.delegate?.navigateToTransactionDetail(id: transaction.id)
                        }

                    if index < viewModel.transactions.count - 1 {
                        Divider()
                            .padding(.leading, 60)
                    }
                }
            }
            .background(Material.regular)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Palette.staticBlack.swiftUI.opacity(0.1), radius: 8, x: 0, y: 2)
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct CardDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let _ = Container.shared.cardsRepository.register { MockCardsRepositoryForDetail() }
        return CardDetailView(viewModel: .init(card: Card.mocks[0]))
    }
}

private final class MockCardsRepositoryForDetail: CardsRepositoryProtocol {
    func fetchCards() async throws -> [Card] { Card.mocks }
    func fetchTransactions(for cardId: String) async throws -> [Transaction] {
        Transaction.mocks.filter { $0.cardId == cardId }
    }
}
#endif
