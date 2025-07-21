//
//  AccountDetailViewModel.swift
//  TransparentAccounts_useCase
//
//  Created by Jakub Jelinek on 21/07/2025.
//

import Foundation

@MainActor
final class AccountDetailViewModel: ObservableObject {
    @Published var transactions: [TransparentTransaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let account: TransparentAccount
    private let repository: TransparentAccountsRepository

    init(account: TransparentAccount, repository: TransparentAccountsRepository) {
        self.account = account
        self.repository = repository
    }

    func loadTransactions() {
        guard let accountId = account.accountNumber.value else {
            self.errorMessage = "Neplatné ID účtu"
            return
        }

        isLoading = true
        errorMessage = nil

        // Hardcoded rozmezí pro testy (lze nahradit parametry později)
        let dateFrom = "2016-08-01T00:00:00"
        let dateTo = "2016-09-01T00:00:00"

        repository.getTransactions(accountId: accountId, dateFrom: dateFrom, dateTo: dateTo) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let transactions):
                    self?.transactions = transactions
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

