//  CardDetailViewController.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import SwiftUI
import CoreModels

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

    func showError(_ error: ServerError) {
        let alert = UIAlertController(
            title: error.title ?? "Something went wrong",
            message: error.message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

