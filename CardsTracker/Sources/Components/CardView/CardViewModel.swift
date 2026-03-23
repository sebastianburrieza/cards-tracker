//  CardViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI

enum CardType {
    case debitVirtual
    case debitPlastic
    case creditVirtual
    case creditPlastic
    case skeleton
    case failure
}

final class CardViewModel: ObservableObject {
    
    @Published var type: CardType = .debitVirtual
    @Published var color: ColorCode = .PINK
    @Published var hexa: String?
    
    @Published var isLoading: Bool = false
    
    init() { }
    
    func draw(type: CardType, color: ColorCode, hexa: String? = nil) {
        self.type = type
        self.color = color
        self.hexa = hexa
        
        if type == .skeleton { isLoading = true }
        else { isLoading = false }
    }
    
    var shouldShowVirtualLabel: Bool {
        type == .debitVirtual || type == .creditVirtual
    }
    
    var shouldShowStrokeBorder: Bool {
        type == .failure
    }
    
    var isVertical: Bool {
        type != .debitVirtual && type != .debitPlastic
    }
    
    var visaAndContactlessColor: Color {
        switch (type, color) {
        case (.creditPlastic, .PINK):
            return .black
        case (.skeleton, _):
            return Palette.grayMedium.swiftUI
        case (.failure, _):
            return Palette.grayMedium.swiftUI
        default:
            return .white
        }
    }
    
    var brubankLogoColor: Color {
        switch (type, color) {
        case (.creditPlastic, .PINK):
            return colors.first?.adjust(saturation: 0.3).darkenColor(by: 0.7).opacity(0.3) ?? .white.opacity(0.9)
        case (.creditPlastic, .GREEN):
            return colors.first?.darkenColor(by: 0.7) ?? .white.opacity(0.3)
        case (.creditPlastic, .PURPLE):
            return colors.first?.darkenColor(by: 0.7) ?? .white.opacity(0.3)
        default:
            return .white
        }
    }
    
    var colors: [Color] {
        if let hex = hexa, !hex.isEmpty {
            switch color {
            case .VIOLET, .PINK, .GREEN, .ORANGE:
                return [Color(hex: "\(hex)").adjust(brightness: 0.2), Color(hex: "\(hex)")]
            case .PURPLE:
                return [Color(hex: "\(hex)").adjust(brightness: 0.5), Color(hex: "\(hex)")]
            case .WHITE, .SKELETON:
                break
            }
        }
        
        switch color {
        case .VIOLET, .SKELETON:
            return [Palette.violet.swiftUI.adjust(brightness: 0.3), Palette.violet.swiftUI]
        case .PINK:
            return [Palette.pink.swiftUI.adjust(brightness: 0.3), Palette.pink.swiftUI]
        case .GREEN:
            return [Palette.green.swiftUI.adjust(brightness: 0.3), Palette.green.swiftUI]
        case .PURPLE:
            return [Palette.purple.swiftUI.adjust(brightness: 0.3), Palette.purple.swiftUI]
        case .ORANGE:
            return [Palette.orange.swiftUI.adjust(brightness: 0.3), Palette.orange.swiftUI]
        case .WHITE:
            return [Color(hex: "#CA2DB6"), Color(hex: "#6049D9")]
        }
    }
    
    func changeColor(_ color: ColorCode) {
        self.color = color
    }
    
}

enum ColorCode: String, Codable {
    case WHITE
    case PINK
    case VIOLET
    case GREEN
    case PURPLE
    case ORANGE
    
    case SKELETON
}
