//
//  AccountDetailView.swift
//  TransparentAccounts_useCase
//
//  Created by Jakub Jelinek on 21/07/2025.
//

import SwiftUI

struct AccountDetailView: View {
    let account: TransparentAccount
    @StateObject private var viewModel: AccountDetailViewModel
    
    init(account: TransparentAccount, repository: TransparentAccountsRepository = .mock) {
        self.account = account
        _viewModel = StateObject(wrappedValue: AccountDetailViewModel(account: account, repository: repository))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(account.name.value ?? "Neznámý název")
                .font(.largeTitle)
                .bold()
            
            if let balance = account.balance.value {
                Text("Zůstatek: \(balance, specifier: "%.2f") \(account.currency?.value ?? "Měna není k dispozici")")
            }
            
            if let iban = account.iban.value {
                Text("IBAN: \(iban)")
            }
            
            if let note = account.note?.value {
                Text("Poznámka: \(note)")
            }
            
            Spacer()
            
            if viewModel.isLoading {
                ProgressView("Načítám transakce...")
            } else if let error = viewModel.errorMessage {
                Text("❌ Chyba: \(error)")
                    .foregroundColor(.red)
            } else {
                List(viewModel.transactions) { transaction in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(transaction.typeDescription)
                            .font(.headline)
                        
                        Text("Částka: \(transaction.amount.value, specifier: "%.2f") \(transaction.amount.currency)")
                        
                        if let senderName = transaction.sender.name {
                            Text("Odesílatel: \(senderName)")
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Datum: \(transaction.processingDate)")
                            .font(.caption)
                    }
                }
                .listStyle(.plain)
            }
        }
        .padding()
        .navigationTitle("Detail účtu")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadTransactions()
        }
    }
}

#Preview {
    AccountDetailView(account: TransparentAccount.mockDetail)
}
