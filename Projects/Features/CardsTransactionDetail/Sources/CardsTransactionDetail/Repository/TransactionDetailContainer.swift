//  TransactionDetailContainer.swift
//  Created by Sebastian Burrieza on 12/04/2026.

import Factory

extension Container {

    /// Repository for the CardsTransactionDetail feature.
    ///
    /// Override in unit tests:
    /// ```swift
    /// Container.shared.transactionDetailRepository.register { MockTransactionDetailRepository() }
    /// ```
    var transactionDetailRepository: Factory<any TransactionDetailRepositoryProtocol> {
        self { MockTransactionDetailRepository() }.singleton
    }
}
