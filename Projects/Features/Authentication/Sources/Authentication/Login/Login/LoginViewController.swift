//  LoginViewController.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit
import SwiftUI

final class LoginViewController: UIHostingController<LoginView> {

    weak var coordinator: AuthCoordinator?

    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(rootView: LoginView(viewModel: viewModel))
        viewModel.delegate = self
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension LoginViewController: LoginNavigationDelegate {

    func loginDidSucceed() {
        coordinator?.loginDidSucceed()
    }
}
