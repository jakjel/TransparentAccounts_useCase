//
//  model.swift
//  TransparentAccounts_useCase
//
//  Created by Jakub Jelinek on 18/07/2025.
//

import Foundation

struct Safe<T: Decodable>: Decodable {
    let value: T?
    
    init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer()
        self.value = try? container?.decode(T.self)
    }
    
    init(value: T?) {
        self.value = value
    }
}

/// Transparent account
struct TransparentAccountResponse: Decodable {
    let pageNumber: Safe<Int>
    let pageCount: Safe<Int>
    let pageSize: Safe<Int>
    let recordCount: Safe<Int>
    let nextPage: Safe<Int>?
    let accounts: [TransparentAccount]
}

struct TransparentAccount: Decodable, Identifiable{
    var id: String {
        accountNumber.value ?? "Nepodařilo se dekódovat!"
    }
    let accountNumber: Safe<String>
    let bankCode: Safe<String>
    let transparencyFrom: Safe<String>
    let transparencyTo: Safe<String>
    let publicationTo: Safe<String>
    let actualizationDate: Safe<String>
    let balance: Safe<Double>
    let currency: Safe<String>?
    let name: Safe<String>
    let description: Safe<String>?
    let note: Safe<String>?
    let iban: Safe<String>
    let statements: Safe<[String]>?
}

/// Transparent transaction
struct TransparentTransactionsResponse: Decodable {
    let pageNumber: Int
    let pageSize: Int
    let pageCount: Int
    let nextPage: Int?
    let recordCount: Int
    let transactions: [TransparentTransaction]
}

struct TransparentTransaction: Decodable, Identifiable {
    var id: UUID = UUID()
    let amount: Amount
    let type: String
    let dueDate: String
    let processingDate: String
    let sender: TransactionParty
    let receiver: TransactionParty
    let typeDescription: String
    
    private enum CodingKeys: String, CodingKey {
        case amount, type, dueDate, processingDate, sender, receiver, typeDescription
    }
}

struct Amount: Decodable {
    let value: Double
    let precision: Int
    let currency: String
}

// Sender and Receiver
struct TransactionParty: Decodable {
    let accountNumber: String
    let bankCode: String
    let iban: String
    let specificSymbol: String?
    let specificSymbolParty: String?
    let variableSymbol: String?
    let constantSymbol: String?
    let name: String?
    let description: String?
}

// Mock pro #Preview a testovani
extension TransparentAccount {
    static var mockDetail: TransparentAccount {
        TransparentAccount(
            accountNumber: Safe(value: "000000-2906478309"),
            bankCode: Safe(value: "0800"),
            transparencyFrom: Safe(value: "2020-01-01T00:00:00"),
            transparencyTo: Safe(value: "3000-01-01T00:00:00"),
            publicationTo: Safe(value: "3000-01-01T00:00:00"),
            actualizationDate: Safe(value: "2024-01-01T12:00:00"),
            balance: Safe(value: 98765.43),
            currency: Safe(value: "CZK"),
            name: Safe(value: "Detailní účet"),
            description: Safe(value: "Ukázkový detail"),
            note: Safe(value: "Poznámka k účtu"),
            iban: Safe(value: "CZ00 0800 0000 0012 3456 7890"),
            statements: Safe(value: ["statement1.pdf", "statement2.xml"])
        )
    }
}
