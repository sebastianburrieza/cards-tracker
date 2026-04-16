//  CardListItemView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI
import Utilities
import CoreModels

struct CardListItemView: View {

    @State var viewModel: CardListItemViewModel

    var body: some View {
        HStack(spacing: 8) {
            CardView(
                type: viewModel.card.type,
                color: viewModel.card.color,
                hexa: viewModel.card.hexa,
                size: 110,
                isShadow: false
            )

            VStack(alignment: .leading, spacing: 8) {
                amountRow
                progressBar
                dueDateLabel
                holderName
            }
            .padding(.leading, 8)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Palette.grayMedium.swiftUI)
                .padding(.leading, -8)
        }
        .padding(8)
        .background(Material.regular)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Palette.staticBlack.swiftUI.opacity(0.1), radius: 8, x: 0, y: 2)
        // Accessibility: merge all child elements into one VoiceOver item
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.accessibilityLabel)
        .accessibilityHint("Double-tap to open card detail")
    }

    // MARK: Amount row

    @ViewBuilder
    private var amountRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(viewModel.formattedAmountUsed)
                .font(Fonts.bold(size: 20))
                .foregroundColor(Palette.grayUltraDark.swiftUI)
            
            Spacer()

            Text(viewModel.formattedRemaining)
                .font(Fonts.regular(size: 13))
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
                    .frame(height: 16)

                RoundedRectangle(cornerRadius: 8)
                    .fill(viewModel.progressColor)
                    .frame(width: geo.size.width * viewModel.progress, height: 16)
            }
        }
        .frame(height: 12)
    }

    // MARK: Due date

    @ViewBuilder
    private var dueDateLabel: some View {
        Text(viewModel.dueDateLabel)
            .font(Fonts.regular(size: 12))
            .foregroundColor(Palette.grayMedium.swiftUI)
    }

    // MARK: Holder name

    @ViewBuilder
    private var holderName: some View {
        Text(viewModel.card.holderName)
            .font(Fonts.medium(size: 18))
            .foregroundColor(Palette.grayUltraDark.swiftUI)
    }
}
