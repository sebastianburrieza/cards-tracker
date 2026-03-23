//  ListView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI

struct ListView: View {

    @ObservedObject var viewModel: ListViewModel = .init()

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
            NavigationBarView(leftView: LeftButtonView(action: {}, buttonType: .back),
                              middleView: AnyView(Text(CardsTrackerStrings.Card.List.title)
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
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

// MARK: - Preview

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
