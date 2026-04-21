//  TransactionListItemView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import CoreModels
import ComponentsUI
import ResourcesUI
import Utilities

struct TransactionItemView: View {

    @State var viewModel: TransactionItemViewModel
    
    var onTapped: ((CoreModels.Transaction) -> Void)?

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
            
            AmountText(value: viewModel.transaction.amount,
                       hasSign: false,
                       currency: viewModel.transaction.currency,
                       font: Fonts.medium(size: 15))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .onTapGesture {
            onTapped?(viewModel.transaction)
        }
        // Accessibility: merge icon + texts + amount into one VoiceOver item
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(viewModel.transaction.merchantName), \(viewModel.formattedAmount), \(viewModel.formattedDate)")
        .accessibilityHint("Double-tap to see transaction detail")
    }
}
