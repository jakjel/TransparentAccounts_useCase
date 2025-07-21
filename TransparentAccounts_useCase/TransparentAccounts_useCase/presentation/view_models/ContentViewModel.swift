//
//  ContentViewModel.swift
//  TransparentAccounts_useCase
//
//  Created by Jakub Jelinek on 19/07/2025.
//

import Foundation

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var accounts: [TransparentAccount] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let repository: TransparentAccountsRepository
    
    private var currentPage = 0
    private let pageSize = 25
    private var canLoadMore = true
    private var isInitialLoad = true
    
    init(repository: TransparentAccountsRepository) {
        self.repository = repository
    }
    
    func loadAccounts(forceRefresh: Bool = false) {
        guard !isLoading, canLoadMore else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Pokud jde o první načtení nebo force refresh, resetuj
        if forceRefresh || isInitialLoad {
            currentPage = 0
            canLoadMore = true
            accounts = []
            isInitialLoad = false
        }
        
        repository.getAccounts(page: currentPage, size: pageSize, forceRefresh: forceRefresh) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let newAccounts):
                    self?.accounts.append(contentsOf: newAccounts)
                    self?.canLoadMore = newAccounts.count == self?.pageSize
                    if self?.canLoadMore == true {
                        self?.currentPage += 1
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func getAccountDetail(id: String, completion: @escaping (TransparentAccount?) -> Void) {
        repository.getAccountDetail(id: id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let account):
                    completion(account)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(nil)
                }
            }
        }
    }
}

