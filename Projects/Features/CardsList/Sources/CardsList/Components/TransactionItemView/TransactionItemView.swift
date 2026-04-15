//  TransactionListItemView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import CoreModels
import ResourcesUI
import Utilities

struct TransactionItemView: View {

    @ObservedObject var viewModel: TransactionItemViewModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: viewModel.categoryIcon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(viewModel.categoryColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.transaction.merchantName)
                    .font(Fonts.medium(size: 16))
                    .foregroundColor(Palette.grayUltraDark.swiftUI)

                Text(viewModel.formattedDate)
                    .font(Fonts.regular(size: 12))
                    .foregroundColor(Palette.grayMedium.swiftUI)
            }

            Spacer()

            Text(viewModel.formattedAmount)
                .font(Fonts.medium(size: 15))
                .foregroundColor(Palette.grayUltraDark.swiftUI)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Preview

struct TransactionItemView_Previews: PreviewProvider {
    static var previews: some View {
        TransactionItemView(viewModel: .init(transaction: CoreModels.Transaction.mock()))
            .previewLayout(.sizeThatFits)
    }
}
