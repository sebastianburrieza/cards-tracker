//  CardDetailViewController.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import SwiftUI
import CoreModels
import CardsTransactionDetailInterface

final class CardDetailViewController: UIHostingController<CardDetailView> {
    
    var coordinator: CardDetailCoordinator?
    
    private let viewModel: CardDetailViewModel
    
    init(viewModel: CardDetailViewModel) {
        self.viewModel = viewModel
        
        super.init(rootView: .init(viewModel: viewModel))
        self.viewModel.delegate = self
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        fetch()
    }
    
    private func fetch() {
        Task {
            await viewModel.fetchTransactions()
        }
    }
    
}

extension CardDetailViewController: CardDetailNavigationDelegate {

    func navigateToPrevious() {
        coordinator?.navigateToPrevious(true)
    }

    func navigateToTransactionDetail(id: String) {
        let route = TransactionDetailRoute(transactionId: id)
        Task { @MainActor in
            await coordinator?.router.navigate(
                to: route,
                fromCoordinator: coordinator,
                navigationType: .present(.overFullScreen, false)
            )
        }
    }

    func navigateToSettings() {
        coordinator?.navigateToSettings()
    }

}
