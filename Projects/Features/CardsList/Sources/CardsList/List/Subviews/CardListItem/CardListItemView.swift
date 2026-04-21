//  CardListItemView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI
import Utilities
import CoreModels

struct CardListItemView: View {

    @State var viewModel: CardListItemViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .top, spacing: 6) {
                cardView
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 8) {
                    amountRow
                    progressBar
                    dueDateLabel
                }
                .padding(.leading, 8)
            }
            
            HStack(alignment: .center, spacing: 6) {
                bottomInfoRow
                    .padding(.top, 4)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(Fonts.medium(size: 18))
                    .foregroundColor(Palette.grayMedium.swiftUI)
                    .padding(.top, 8)
            }
        }
        .padding(12)
        .background(Palette.backgroundLight.swiftUI)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Palette.staticBlack.swiftUI.opacity(0.1), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.accessibilityLabel)
        .accessibilityHint("Doble tap para abrir el detalle de la tarjeta")
    }

    // MARK: Card thumbnail

    @ViewBuilder
    private var cardView: some View {
        CardView(
            type: viewModel.card.type,
            brand: viewModel.card.brand,
            color: viewModel.card.color,
            hexa: viewModel.card.hexa,
            size: 110,
            isShadow: false
        )
        .frame(width: 110, height: 70)
    }

    // MARK: Amount row

    @ViewBuilder
    private var amountRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(viewModel.formattedAmountUsed)
                .font(Fonts.bold(size: 18))
                .foregroundColor(Palette.grayUltraDark.swiftUI)

            Spacer()

            Text(viewModel.formattedRemaining)
                .font(Fonts.regular(size: 10))
                .foregroundColor(Palette.grayMedium.swiftUI)
        }
    }

    // MARK: Progress bar

    @ViewBuilder
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Palette.grayUltraLight.swiftUI)
                    .frame(height: 10)

                RoundedRectangle(cornerRadius: 8)
                    .fill(viewModel.progressColor)
                    .frame(width: geo.size.width * viewModel.progress, height: 10)
            }
        }
        .frame(height: 10)
    }

    // MARK: Due date

    @ViewBuilder
    private var dueDateLabel: some View {
        Text(viewModel.dueDateLabel)
            .font(Fonts.thin(size: 14))
            .foregroundColor(Palette.grayMedium.swiftUI)
    }

    // MARK: Bottom info row

    @ViewBuilder
    private var bottomInfoRow: some View {
        HStack(spacing: 6) {
            Text(viewModel.card.bankName)
                .font(Fonts.medium(size: 20))
                .foregroundColor(Palette.grayUltraDark.swiftUI)

            Text(viewModel.typeLabel)
                .font(Fonts.regular(size: 17))
                .foregroundColor(Palette.grayDark.swiftUI)

            Text(viewModel.maskedLastFour)
                .font(Fonts.regular(size: 17))
                .foregroundColor(Palette.grayUltraDark.swiftUI)
        }
    }
}
