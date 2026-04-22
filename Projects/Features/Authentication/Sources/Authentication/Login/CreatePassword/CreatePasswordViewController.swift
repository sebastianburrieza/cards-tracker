//  CreatePasswordViewController.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import SwiftUI

final class CreatePasswordViewController: UIHostingController<CreatePasswordView> {

    weak var coordinator: AuthCoordinator?

    private let viewModel: CreatePasswordViewModel

    init(viewModel: CreatePasswordViewModel) {
        self.viewModel = viewModel
        super.init(rootView: CreatePasswordView(viewModel: viewModel))
        viewModel.delegate = self
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension CreatePasswordViewController: CreatePasswordNavigationDelegate {

    func passwordCreated() {
        coordinator?.passwordCreated()
    }
}
