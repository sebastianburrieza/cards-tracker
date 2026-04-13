//  TransactionDetailViewController.swift
//  Created by Sebastian Burrieza on 12/04/2026.

import UIKit
import SwiftUI

/// Hosts the ``TransactionDetailView`` bottom sheet.
///
/// Present this controller **modally** with `.overCurrentContext` + `.crossDissolve`
/// so the dimmed background shows through.
final class TransactionDetailViewController: UIHostingController<TransactionDetailView> {

    private let viewModel: TransactionDetailViewModel

    init(viewModel: TransactionDetailViewModel) {
        self.viewModel = viewModel
        super.init(rootView: TransactionDetailView(viewModel: viewModel))

        // Transparent host so the overlay covers the full screen.
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        view.backgroundColor = .clear

        self.viewModel.delegate = self
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            await viewModel.fetchTransaction()
        }
    }
}

// MARK: - TransactionDetailNavigationDelegate

extension TransactionDetailViewController: TransactionDetailNavigationDelegate {

    func dismiss() {
        dismiss(animated: false)
    }
}
