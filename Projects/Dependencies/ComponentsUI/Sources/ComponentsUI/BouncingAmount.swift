//  BouncingAmount.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI
import CoreModels
import Extensions

public struct BouncingAmount: View {
    
    @Binding var value: Int
    var font: Font
    @Binding var fontColor: Color
    var currency: Currency
    
    let positiveAmountColor = Palette.black
    let negativeAmountColor = Palette.green
    let decimalAlpha: CGFloat = 0.5
    
    public init(value: Binding<Int>,
                font: Font,
                fontColor: Binding<Color>,
                currency: Currency) {
        self._value = value
        self.font = font
        self._fontColor = fontColor
        self.currency = currency
    }
    
    public var body: some View {
        
        Text(formatter(value))
            .font(font)
            .contentTransition(.numericText())
            .animation(.spring, value: value)
            .onChange(of: value) { _, newValue in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    value = newValue
                }
            }
    }
    
    private func formatter(_ value: Int) -> AttributedString {
        NumberFormatter.formatAmount(value,
                                     positiveColor: fontColor,
                                     decimalAlpha: decimalAlpha,
                                     hasSign: false,
                                     currency: currency)
    }
}

struct AmountSkeleton: View {
    
    var width: CGFloat = 150
    var height: CGFloat = 27
    var cornerRadius: CGFloat = 7
    var color: Color = Palette.grayMedium.swiftUI
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .foregroundStyle(color)
            .frame(width: width, height: height)
            .opacity(0.7)
            .isSkeletonView(true)
    }
}
