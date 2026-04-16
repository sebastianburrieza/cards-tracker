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
            background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                cardList
            }
        }
        .safeAreaInset(edge: .top) {
            navigationBarView
                .background(Material.ultraThin)
        }
        .task { await viewModel.fetchCards() }
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
        VStack {
            NavigationBarView(
                middleView: AnyView(
                    Text(CardsListStrings.Card.List.title)
                        .font(Fonts.medium(size: 21))
                )
            )
        }
    }

    // MARK: Card list

    @ViewBuilder
    private var cardList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(viewModel.cards) { card in
                    CardListItemView(viewModel: .init(card: card))
                        .onTapGesture {
                            viewModel.delegate?.navigateToDetail(card: card)
                        }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = ListViewModel()
        _ = Container.shared.cardsRepository.register { MockCardsRepository() }
        return ListView(viewModel: vm)
    }
}

private final class MockCardsRepository: CardsRepositoryProtocol {
    
    func createCard(_ card: Card) async -> Result<Card, ServerError> {
        .failure(.unexpected)
    }
    
    func updateCard(_ card: Card) async -> Result<Card, ServerError> {
        .failure(.unexpected)
    }
    
    func deleteCard(id: String) async -> Result<Void, ServerError> {
        .failure(.unexpected)
    }
    
    func fetchCards() async -> Result<[Card], ServerError> { .success(Card.mocks) }
    
    func fetchCard(id: String) async -> Result<CoreModels.Card, CoreModels.ServerError> {
        .success(Card.mocks.first!)
    }
    
    func fetchTransactions(for cardId: String) async -> Result<[CoreModels.Transaction], ServerError> {
        .success(CoreModels.Transaction.mocks.filter { $0.cardId == cardId })
    }
}

extension Card {
    
    static let mocks: [Card] = [
        Card.mock(id: "550e8400-e29b-41d4-a716-446655440000",
                  type: .creditPlastic,
                  color: .GREEN,
                  holderName: "Sebastian A Burrieza",
                  limit: 220_000_000,
                  available: 33_250_000),
        Card.mock(id: "550e8400-e29b-41d4-a716-446655440001",
                  type: .creditPlastic,
                  color: .PURPLE,
                  holderName: "Sebastian A Burrieza",
                  limit: 200_000_000,
                  available: 183_250_000)
    ]
}

public extension CoreModels.Transaction {
    
    static let mocks: [CoreModels.Transaction] = [
        Transaction.mock(id: "660e8400-e29b-41d4-a716-446655440010",
                         merchantName: "Confiteria Paris",
                         amount: 1199000,
                         cardId: "550e8400-e29b-41d4-a716-446655440000",
                         category: .restaurant),
        Transaction.mock(id: "660e8400-e29b-41d4-a716-446655440011",
                         merchantName: "Pedidos Ya",
                         amount: 372300099,
                         cardId: "550e8400-e29b-41d4-a716-446655440000",
                         category: .delivery),
        Transaction.mock(id: "660e8400-e29b-41d4-a716-446655440020",
                         merchantName: "Mercado Libre",
                         amount: 18990050,
                         cardId: "550e8400-e29b-41d4-a716-446655440001",
                         category: .shopping)
    ]
}
#endif
