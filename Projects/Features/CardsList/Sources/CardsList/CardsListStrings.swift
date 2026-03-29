//  CardsListStrings.swift
//  Created by Sebastian Burrieza on 01/04/2026.
//
//  Strings del módulo CardsList.
//  Usa Bundle.main porque CardsList es un staticFramework
//  que se linkea en el app bundle.
//  Tuist reemplazará este archivo con TuistStrings+CardsList.swift
//  al correr `tuist generate`.

import Foundation

enum CardsListStrings {
    enum Card {
        enum List {
            static let title = NSLocalizedString("card.list.title", bundle: .main, comment: "")
        }
        enum DueDate {
            static let singular = NSLocalizedString("card.dueDate.singular", bundle: .main, comment: "")
            static func plural(_ count: Int) -> String {
                String(format: NSLocalizedString("card.dueDate.plural", bundle: .main, comment: ""), count)
            }
        }
        enum Detail {
            static let consumos = NSLocalizedString("card.detail.consumos", bundle: .main, comment: "")
            static func disponible(_ amount: String) -> String {
                String(format: NSLocalizedString("card.detail.disponible", bundle: .main, comment: ""), amount)
            }
            static let pausar   = NSLocalizedString("card.detail.pausar",   bundle: .main, comment: "")
            static let reportar = NSLocalizedString("card.detail.reportar", bundle: .main, comment: "")
        }
    }
}
