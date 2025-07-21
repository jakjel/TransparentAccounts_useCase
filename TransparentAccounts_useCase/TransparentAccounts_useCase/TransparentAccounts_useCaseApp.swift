//
//  TransparentAccounts_useCaseApp.swift
//  TransparentAccounts_useCase
//
//  Created by Jakub Jelinek on 18/07/2025.
//

import SwiftUI

@main
struct TransparentAccounts_useCaseApp: App {
    private let repository = TransparentAccountsRepository()

    var body: some Scene {
        WindowGroup {
            ContentView(repository: repository)
        }
    }
}

