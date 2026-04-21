//  CardsView.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import CoreModels
import ResourcesUI
import Utilities

struct CardView: View {
    
    @ObservedObject var viewModel: CardViewModel = .init()
    
    private var brand: CardBrand?
    private var height: CGFloat = 200
    private var isShadow: Bool = true
    private var isPaused: Bool = false
    private var lastFour: String?
    
    init(type: CardType = .creditPlastic,
         brand: CardBrand? = nil,
         color: ColorCode = .PINK,
         hexa: String? = nil,
         size: CGFloat,
         isPaused: Bool = false,
         lastFour: String? = nil,
         isShadow: Bool = true) {
        self.viewModel = viewModel
        
        self.brand = brand
        self.height = size
        self.isShadow = isShadow
        self.isPaused = isPaused
        self.lastFour = lastFour
        
        viewModel.draw(type: type, color: color, hexa: hexa)
    }

    var body: some View {
        ZStack {
            shadow
        
            if viewModel.shouldShowStrokeBorder {
                strokeCard
            } else {
                filledCard
            }
            
            if viewModel.isVertical {
                verticalCard
            } else {
                horizontalCard
            }
            
            pausedLabel
                .opacity(isPaused ? 1 : 0)
                .animation(.easeInOut(duration: 0.5), value: isPaused)
        }
        .isSkeletonView(viewModel.isLoading)
    }
    
    @ViewBuilder
    private var filledCard: some View {
        LinearGradient(gradient: Gradient(colors: viewModel.colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            .frame(width: viewModel.isVertical ? height * 0.63 : height,
                   height: viewModel.isVertical ? height : height * 0.63)
            .clipShape(RoundedRectangle(cornerRadius: height * 0.1))
            .grayscale(isPaused ? 0.2 : 0)
    }
    
    @ViewBuilder
    private var strokeCard: some View {
        RoundedRectangle(cornerRadius: height * 0.04)
            .stroke(viewModel.type == .failure ? Palette.grayMedium.swiftUI :
                        Palette.primary.swiftUI, style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
            .frame(width: viewModel.isVertical ? height * 0.63 : height,
                   height: viewModel.isVertical ? height : height * 0.63)
    }
    
    @ViewBuilder
    private var verticalCard: some View {
        ZStack {
            virtualLabel
                .scaleEffect(max(height / 200, 0.2))
                .offset(y: -height * 0.35)
                .isHidden(!viewModel.shouldShowVirtualLabel)
            
            Group {
                chip
                    .offset(x: height * 0.05, y: -height * 0.35)
                
                contacless
                    .offset(x: height * 0.2, y: -height * 0.35)
            }
            .isHidden(viewModel.shouldShowVirtualLabel)
            .blur(radius: isPaused ? 0.5 : 0)
                
            brandImage
                .offset(x: height * 0.11, y: height * 0.37)
                .blur(radius: isPaused ? 0.5 : 0)
        }
    }
    
    @ViewBuilder
    private var horizontalCard: some View {
        ZStack {
            virtualLabel
                .scaleEffect(max(height / 250, 0.2))
                .offset(x: height * 0.3, y: height * 0.08)
                .isHidden(!viewModel.shouldShowVirtualLabel)
            
            Group {
                chip
                    .offset(x: -height * 0.37, y: -height * 0.02)
                
                contacless
                    .offset(x: -height * 0.38, y: -height * 0.17)
            }
            .isHidden(viewModel.shouldShowVirtualLabel)
            .blur(radius: isPaused ? 2 : 0)
                
            brandImage
                .offset(x: height * 0.27, y: height * 0.08)
                .blur(radius: isPaused ? 2 : 0)
            
            if let lastFour, !isPaused {
                lastFourLabel(lastFour: lastFour)
            }
        }
    }
    
    @ViewBuilder
    private var shadow: some View {
        if isShadow {
            let width = viewModel.isVertical ? height * 0.6 : height
            let height = viewModel.isVertical ? height : height * 0.6
            RoundedRectangle(cornerRadius: height * 0.04)
                .fill(Color.white)
                .frame(width: width, height: height)
                .shadow(color: Palette.staticBlack.swiftUI.opacity(0.15), radius: 5, x: 0, y: 0)
        }
    }
    
    @ViewBuilder
    private var brandImage: some View {
        let width = height * 0.4
        let height = height * 0.4
        let brandString = brand?.rawValue ?? "visa"
        Image(brandString)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.clear)
            .frame(width: width, height: height, alignment: .bottom)
    }
    
    @ViewBuilder
    private var chip: some View {
        Image("chip")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .rotationEffect(.degrees(viewModel.isVertical ? -90 : 0))
            .frame(width: height * 0.13, height: height * 0.13)
    }
    
    @ViewBuilder
    private var contacless: some View {
        Image("contactless")
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(viewModel.visaAndContactlessColor)
            .frame(width: height * 0.12, height: height * 0.12)
    }
    
    @ViewBuilder
    private var virtualLabel: some View {
        Text("VIRTUAL".localized.uppercased())
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.2))
            )
    }
    
    @ViewBuilder
    private var pausedLabel: some View {
        Text("PAUSED".localized.uppercased())
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(Palette.grayUltraDark.swiftUI)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Material.ultraThin)
            )
            .scaleEffect(max(height / 200, 0.2))
    }
    
    @ViewBuilder
    private func lastFourLabel(lastFour: String) -> some View {
        Text("**** \(lastFour)")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .offset(x: -height * 0.23, y: height * 0.2)
    }
    
}
