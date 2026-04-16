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
            background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                transactionsListView
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
        NavigationBarView(
            leftView: LeftButtonView(type: .back, action: {
                viewModel.delegate?.navigateToPrevious()
            }),
            middleView: Text(viewModel.card.holderName)
                .font(Fonts.medium(size: 18))
                .foregroundColor(Palette.grayUltraDark.swiftUI),
            rightView: cardView
                .onTapGesture {
                    viewModel.delegate?.navigateToPrevious()
                }
        )
    }

    private var cardView: some View {
        CardView(
            type: viewModel.card.type,
            color: viewModel.card.color,
            hexa: viewModel.card.hexa,
            size: 36,
            isShadow: false
        )
    }

    // MARK: Header

    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 4) {
            Text("DETAIL_TITLE".localized)
                .font(Fonts.regular(size: 24))
                .foregroundColor(Palette.grayDark.swiftUI)

            Text(viewModel.formattedAmountUsed)
                .font(Fonts.bold(size: 36))
                .foregroundColor(Palette.grayUltraDark.swiftUI)

            Text(viewModel.formattedRemaining)
                .font(Fonts.regular(size: 21))
                .foregroundColor(Palette.grayMedium.swiftUI)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Action buttons

    @ViewBuilder
    private var actionButtons: some View {
        HStack(spacing: 12) {
            pauseButton
            reportButton
        }
        .disabled(viewModel.isSubmitting)
        .opacity(viewModel.isSubmitting ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isSubmitting)
    }

    // Pause / Activate button — label changes based on current isPaused state
    private var pauseButton: some View {
        Button(action: {
            Haptic.selection()
            Task { await viewModel.pauseCard() }
        }, label: {
            HStack(spacing: 8) {
                Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text(viewModel.isPaused ? "DETAIL_ACTIVATE".localized : "DETAIL_PAUSE".localized)
                    .font(Fonts.medium(size: 16))
            }
            .foregroundColor(Palette.staticWhite.swiftUI)
            .frame(width: 120)
            .padding(.vertical, 12)
            .background(viewModel.isPaused ? Palette.orange.swiftUI : Palette.yellow.swiftUI)
            .clipShape(Capsule())
        })
        .accessibilityLabel(viewModel.isPaused ? "Tarjeta activa" : "Tarjeta pausada")
        .accessibilityHint("Doble tap para \(viewModel.isPaused ? "activar" : "pausar") esta tarjeta")
    }

    // Report button
    private var reportButton: some View {
        Button(action: {
            Haptic.selection()
            Task { await viewModel.reportCard() }
        }, label: {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14, weight: .semibold))
                Text("DETAIL_REPORT".localized)
                    .font(Fonts.medium(size: 16))
            }
            .foregroundColor(Palette.staticWhite.swiftUI)
            .frame(width: 120)
            .padding(.vertical, 12)
            .background(Palette.red.swiftUI)
            .clipShape(Capsule())
        })
        .accessibilityLabel("Reportar tarjeta")
        .accessibilityHint("Doble tap para reportar y dar de baja esta tarjeta")
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
