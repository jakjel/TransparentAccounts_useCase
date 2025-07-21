//
//  TransparentAccountsRepository.swift
//  TransparentAccounts_useCase
//
//  Created by Jakub Jelinek on 19/07/2025.
//
import Foundation

final class TransparentAccountsRepository {
    private let remoteDataSource: ITransparentAccountsDataSource
    private var memoryCache: [TransparentAccount] = []

    // Umoznuje dependency injection
    init(remoteDataSource: ITransparentAccountsDataSource = TransparentAccountsRemoteDataSource()) {
        self.remoteDataSource = remoteDataSource
    }

    // Fetch všechny transparent accounts
    func getAccounts(
        page: Int,
        size: Int = 25,
        forceRefresh: Bool = false,
        completion: @escaping (Result<[TransparentAccount], Error>) -> Void
    ) {
        // Vypneme cache pro vícestránkové dotazy
        if page == 0, !forceRefresh, !memoryCache.isEmpty {
            completion(.success(memoryCache))
            return
        }

        remoteDataSource.fetchAccounts(page: page, size: size) { [weak self] result in
            switch result {
            case .success(let accounts):
                if page == 0 {
                    self?.memoryCache = accounts
                } else {
                    self?.memoryCache += accounts
                }
                completion(.success(accounts))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    
    // Fetch account details by id
    func getAccountDetail(id: String, completion: @escaping (Result<TransparentAccount, Error>) -> Void) {
        remoteDataSource.fetchAccountDetail(id: id) { result in
            completion(result)
        }
    }
    
    // Fetch transactions by account id
    func getTransactions(
        accountId: String,
        dateFrom: String,
        dateTo: String,
        completion: @escaping (Result<[TransparentTransaction], Error>) -> Void
    ) {
        remoteDataSource.fetchTransactions(
            forAccountId: accountId,
            page: 0,
            size: 25,
            sort: "processingDate",
            order: "desc",
            dateFrom: dateFrom,
            dateTo: dateTo,
            filter: nil,
            completion: completion
        )

    }


}

extension TransparentAccountsRepository {
    static let mock: TransparentAccountsRepository = {
        TransparentAccountsRepository(remoteDataSource: MockDataSource())
    }()
}

