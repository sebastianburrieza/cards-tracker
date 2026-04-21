//  AmountText.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI
import CoreModels
import Extensions

public struct AmountText: View {
    
    var value: Int
    var hasSign: Bool
    var currency: Currency?
    var font: Font
    var backgroundColor: Color
    
    let positiveTextColor: Color = Palette.green.swiftUI
    let positiveBackgroundColor: Color = Palette.green.swiftUI.opacity(0.2)
    let negativeTextColor: Color = Palette.black.swiftUI
    let negativeBackgroundColor: Color = .clear
    let decimalAlpha: CGFloat = 0.5
    
    public init(value: Int,
                hasSign: Bool = true,
                currency: Currency? = nil,
                font: Font = Fonts.bold(size: 20)) {
        self.value = value
        self.hasSign = hasSign
        self.currency = currency
        self.font = font
        
        self.backgroundColor = self.value > 0 ? negativeBackgroundColor : positiveBackgroundColor
    }
    
    public var body: some View {
        Text(amountText)
            .font(font)
            .lineLimit(1)
            .scaledToFit()
            .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
    
    private var amountText: AttributedString {
        NumberFormatter.formatAmount(value,
                                     positiveColor: Palette.black.swiftUI,
                                     negativeColor: Palette.green.swiftUI,
                                     decimalAlpha: decimalAlpha,
                                     hasSign: hasSign,
                                     currency: currency)
    }
    
}
