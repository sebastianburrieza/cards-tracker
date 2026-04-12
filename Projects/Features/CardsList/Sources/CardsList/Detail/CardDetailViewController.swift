//  CardDetailViewController.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import SwiftUI
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
}

extension CardDetailViewController: CardDetailNavigationDelegate {

    func navigateToPrevious() {
        coordinator?.navigateToPrevious(true)
    }

    func navigateToTransactionDetail(id: String) {
        let route = CardsTransactionDetailRoute(transactionId: id)
        Task { @MainActor in
            await coordinator?.navigateToRoute(route, navigationType: .present(.overFullScreen, false))
        }
    }
}

