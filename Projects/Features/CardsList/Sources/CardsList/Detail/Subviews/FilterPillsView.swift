//  FilterPillsView.swift
//  Created by Sebastian Burrieza on 21/04/2026.

import SwiftUI
import ResourcesUI

struct FilterPillsView: View {

    @Binding var selectedFilter: TransactionFilter

    var body: some View {
        HStack(spacing: 8) {
            ForEach(TransactionFilter.allCases, id: \.self) { filter in
                pill(filter)
            }
            Spacer()
        }
    }

    @ViewBuilder
    private func pill(_ filter: TransactionFilter) -> some View {
        let isSelected = selectedFilter == filter
        Button(action: { selectedFilter = filter }) {
            Text(filter.label)
                .font(Fonts.regular(size: 15))
                .foregroundColor(isSelected ? Palette.backgroundLight.swiftUI : Palette.grayUltraDark.swiftUI)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(isSelected ? Palette.grayUltraDark.swiftUI : Palette.backgroundLight.swiftUI)
                        .shadow(color: Palette.staticBlack.swiftUI.opacity(0.1), radius: 4, x: 0, y: 2)
                )
        }
    }
}
