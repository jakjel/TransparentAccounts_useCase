import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel

    init(repository: TransparentAccountsRepository) {
        _viewModel = StateObject(wrappedValue: ContentViewModel(repository: repository))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.accounts) { account in
                    AccountRowView(account: account, repository: viewModel.repository)
                        .onAppear {
                            if account.id == viewModel.accounts.last?.id {
                                viewModel.loadAccounts()
                            }

                        }
                }

                if viewModel.isLoading {
                    loadingView
                }

                if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Transparentní účty")
            .onAppear {
                if viewModel.accounts.isEmpty {
                    viewModel.loadAccounts()
                }
            }
        }
    }

    var loadingView: some View {
        HStack {
            Spacer()
            ProgressView("Načítám další...")
            Spacer()
        }
    }

    func errorView(message: String) -> some View {
        HStack {
            Spacer()
            Text("❌ Chyba: \(message)")
                .foregroundColor(.red)
            Spacer()
        }
    }
}

struct AccountRowView: View {
    let account: TransparentAccount
    let repository: TransparentAccountsRepository

    var body: some View {
        NavigationLink(destination: AccountDetailView(account: account, repository: repository)) {
            VStack(alignment: .leading, spacing: 6) {
                Text(account.name.value ?? "Neznámý název")
                    .font(.headline)

                if let balance = account.balance.value {
                    Text("Zůstatek: \(balance, specifier: "%.2f") \(account.currency?.value ?? "(Měna není k dispozici)")")
                        .font(.subheadline)
                } else {
                    Text("Zůstatek není k dispozici")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    ContentView(repository: .mock)
}
