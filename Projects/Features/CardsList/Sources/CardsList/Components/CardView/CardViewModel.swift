//  CardViewModel.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import SwiftUI
import ResourcesUI
import Utilities
import CoreModels

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
        false
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
    
    var colors: [Color] {
        if let hex = hexa, !hex.isEmpty {
            switch color {
            case .VIOLET, .PINK, .GREEN, .ORANGE, .BLUE:
                return [Color(hex: "\(hex)").adjust(brightness: 0.2), Color(hex: "\(hex)")]
            case .PURPLE:
                return [Color(hex: "\(hex)").adjust(brightness: 0.5), Color(hex: "\(hex)")]
            case .WHITE, .SKELETON:
                break
            }
        }
        
        switch color {
        case .BLUE:
            return [Palette.blue.swiftUI.adjust(brightness: 0.3), Palette.blue.swiftUI]
        case .VIOLET:
            return [Palette.violet.swiftUI.adjust(brightness: 0.3), Palette.violet.swiftUI]
        case .PINK:
            return [Palette.pink.swiftUI.adjust(brightness: 0.3), Palette.pink.swiftUI]
        case .GREEN:
            return [Palette.green.swiftUI.adjust(brightness: 0.3), Palette.green.swiftUI]
        case .PURPLE:
            return [Palette.purple.swiftUI.adjust(brightness: 0.3), Palette.purple.swiftUI]
        case .ORANGE:
            return [Palette.orange.swiftUI.adjust(brightness: 0.3), Palette.orange.swiftUI]
        case .SKELETON, .WHITE:
            return [Palette.primary.swiftUI.adjust(brightness: 0.3), Palette.primary.swiftUI]
        }
    }
    
    func changeColor(_ color: ColorCode) {
        self.color = color
    }
    
}
