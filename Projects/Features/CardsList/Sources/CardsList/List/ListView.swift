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
        .toastErrorView(title: viewModel.errorTitle ?? "",
                        message: viewModel.errorMessage,
                        duration: 3,
                        isPresented: $viewModel.isError)
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
                    Text("CARDLIST_TITLE".localized)
                        .font(Fonts.medium(size: 21))
                )
            )
        }
    }

    // MARK: Card list

    @ViewBuilder
    private var cardList: some View {
        ScrollView(showsIndicators: false) {
            // LazyVStack renders only the rows currently visible on screen.
            // Unlike VStack, it does NOT build all cards at once — same idea as UITableView cell reuse.
            LazyVStack(spacing: 16) {
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
