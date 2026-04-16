//  NoTransactionsView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI

struct NoTransactionsView: View {

    var body: some View {

        RoundedRectangle(cornerRadius: 15)
            .foregroundColor(.clear)
            .frame(height: 120, alignment: .center)
            .padding(.horizontal, 20)
            .overlay {
                VStack {
                    Image(systemName: "creditcard.circle")
                        .resizable()
                        .foregroundColor(Palette.grayMedium.swiftUI)
                        .frame(width: 40, height: 40, alignment: .center)

                    Text("EMPTY_TRANSACTIONS_LIST_SELECTED_CARD")
                        .font(Fonts.medium(size: 15))
                        .foregroundColor(Palette.grayMedium.swiftUI)
                }
                .padding(.vertical)
            }
    }
}
