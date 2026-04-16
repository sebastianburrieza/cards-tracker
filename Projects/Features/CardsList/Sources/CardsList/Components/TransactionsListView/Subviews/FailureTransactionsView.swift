//  FailureTransactionsView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI

struct FailureTransactionsView: View {
    
    var body: some View {
        
        RoundedRectangle(cornerRadius: 15)
            .foregroundColor(.clear)
            .frame(height: 130, alignment: .center)
            .cornerRadius(15)
            .padding(.horizontal, 30)
            .overlay {
                VStack {
                    Image(systemName: "x.circle")
                        .resizable()
                        .foregroundColor(Palette.yellow.swiftUI)
                        .frame(width: 40, height: 40, alignment: .center)
                    
                    Text("FAILURE_TRANSACTIONS".localized)
                        .font(Fonts.medium(size: 15))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Palette.yellow.swiftUI)
                        .padding(.horizontal, 50)
                }
                .padding(.vertical)
            }
    }
}
