//
//  ITransparentAccountsDataSource.swift
//  TransparentAccounts_useCase
//
//  Created by Jakub Jelinek on 19/07/2025.
//
protocol ITransparentAccountsDataSource {
    func fetchAccounts(page: Int, size: Int, completion: @escaping (Result<[TransparentAccount], Error>) -> Void)

    func fetchAccountDetail(id: String, completion: @escaping (Result<TransparentAccount, Error>) -> Void)
    
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
      )
}

