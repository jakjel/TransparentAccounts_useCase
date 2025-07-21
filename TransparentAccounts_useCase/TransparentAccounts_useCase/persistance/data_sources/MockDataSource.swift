//
//  MockDataSource.swift
//  TransparentAccounts_useCase
//
//  Created by Jakub Jelinek on 21/07/2025.
//
import Foundation

class MockDataSource: ITransparentAccountsDataSource {
    func fetchTransactions(
        forAccountId id: String,
        page: Int,
        size: Int,
        sort: String,
        order: String,
        dateFrom: String?,
        dateTo: String?,
        filter: String?,
        completion: @escaping (Result<[TransparentTransaction], Error>) -> Void
    ) {
        let mockTransactions: [TransparentTransaction] = [
            TransparentTransaction(
                amount: Amount(value: -123.45, precision: 0, currency: "CZK"),
                type: "30500",
                dueDate: "2025-07-20T00:00:00",
                processingDate: "2025-07-20T00:00:00",
                sender: TransactionParty(
                    accountNumber: "000000-0000000000",
                    bankCode: "0800",
                    iban: "CZ00 0800 0000 0000 0000 0000",
                    specificSymbol: "0000000000",
                    specificSymbolParty: "0000000000",
                    variableSymbol: "1234567890",
                    constantSymbol: "0308",
                    name: "Jan Novák",
                    description: "Platba za služby"
                ),
                receiver: TransactionParty(
                    accountNumber: id,
                    bankCode: "0800",
                    iban: "CZ13 0800 0000 0029 0647 8309",
                    specificSymbol: "0000000000",
                    specificSymbolParty: "0000000000",
                    variableSymbol: "0000000000",
                    constantSymbol: "0000",
                    name: "Jméno příjemce",
                    description: "Popis transakce"
                ),
                typeDescription: "Poplatek"
            )
        ]
        
        completion(.success(mockTransactions))
    }

    // TADY: musíš přidat parametry page a size
    func fetchAccounts(page: Int, size: Int, completion: @escaping (Result<[TransparentAccount], Error>) -> Void) {
        completion(.success([TransparentAccount.mockDetail]))
    }

    func fetchAccountDetail(id: String, completion: @escaping (Result<TransparentAccount, Error>) -> Void) {
        completion(.success(TransparentAccount.mockDetail))
    }
}
