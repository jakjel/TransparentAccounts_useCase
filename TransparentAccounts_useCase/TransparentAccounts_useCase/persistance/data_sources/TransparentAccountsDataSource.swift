//
//  TransparentAccountsDataSource.swift
//  TransparentAccounts_useCase
//
//  Created by Jakub Jelinek on 19/07/2025.
//

import Foundation

final class TransparentAccountsRemoteDataSource: ITransparentAccountsDataSource {
//    private let session: URLSession
//    private let apiKey = "4e899a02-2e14-4856-8173-b57a08b7e247"
//    private let baseURL: URL = URL(string: "https://webapi.developers.erstegroup.com/api/csas/public/sandbox/v3/transparentAccounts")!
//    
//    
//    init(session: URLSession = .shared) {
//        guard let api_url =
//                guard let api_key = Bundle.main.infoDictionary?["API_KEY"] AS String
//        self.session = session
//    }
    
    private let session: URLSession
    private let apiKey: String
    private let baseURL: URL

    init(session: URLSession = .shared) {
        self.session = session
        
        // Načte API klíč z Info.plist
        guard let key = Bundle.main.infoDictionary?["API_KEY"] as? String else {
            fatalError("API_KEY not found in Info.plist")
        }
        self.apiKey = key
        
        // Načte URL z Info.plist
        guard let urlString = Bundle.main.infoDictionary?["TRANSPARENT_ACCOUNTS_API_URL"] as? String,
              let url = URL(string: urlString) else {
            fatalError("TRANSPARENT_ACCOUNTS_API_URL not found or invalid in Info.plist")
        }
        print("BASE_URL from plist:", urlString)
        self.baseURL = url
    }
    
    func fetchAccounts(page: Int = 0, size: Int = 25, completion: @escaping (Result<[TransparentAccount], Error>) -> Void) {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)")
        ]

        var request = URLRequest(url: components.url!)
        request.setValue(apiKey, forHTTPHeaderField: "WEB-API-key")

        let decoder = JSONDecoder()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try decoder.decode(TransparentAccountResponse.self, from: data)
                    completion(.success(response.accounts))
                } catch {
                    print("❌ Decoding failed: \(error)")
                    if let json = String(data: data, encoding: .utf8) {
                        print("🧾 Raw JSON:\n\(json)")
                    }
                    completion(.failure(error))
                }
            } else {
                completion(.failure(error ?? URLError(.badServerResponse)))
            }
        }

        task.resume()
    }
    
    func fetchAccountDetail(id: String, completion: @escaping (Result<TransparentAccount, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL.absoluteString)/\(id)") else {
            completion(.failure(URLError(.badURL)))
            return
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "WEB-API-key")
        let decoder = JSONDecoder()

        let task = session.dataTask(with: request) { data, response, error in
            if let response = response {
                print("ℹ️ Response: \(response)")
            }

            if let data = data {
                if let json = String(data: data, encoding: .utf8) {
                    print("🧾 Raw JSON:\n\(json)")
                }

                do {
                    let account = try decoder.decode(TransparentAccount.self, from: data)
                    completion(.success(account))
                } catch {
                    print("❌ Decoding failed: \(error)")
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(URLError(.unknown)))
            }
        }

        task.resume()
    }
    
    func fetchTransactions(
        forAccountId id: String,
        page: Int = 0,
        size: Int = 25,
        sort: String = "processingDate",
        order: String = "desc",
        dateFrom: String? = nil,
        dateTo: String? = nil,
        filter: String? = nil,
        completion: @escaping (Result<[TransparentTransaction], Error>) -> Void
    ) {
        var components = URLComponents(string: "\(baseURL)/\(id)/transactions")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "size", value: "\(size)"),
            URLQueryItem(name: "sort", value: sort),
            URLQueryItem(name: "order", value: order)
        ]

        if let dateFrom = dateFrom {
            queryItems.append(URLQueryItem(name: "dateFrom", value: dateFrom))
        }
        if let dateTo = dateTo {
            queryItems.append(URLQueryItem(name: "dateTo", value: dateTo))
        }
        if let filter = filter {
            queryItems.append(URLQueryItem(name: "filter", value: filter))
        }

        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.setValue(apiKey, forHTTPHeaderField: "WEB-API-key")

        let decoder = JSONDecoder()

        let task = session.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try decoder.decode(TransparentTransactionsResponse.self, from: data)
                    completion(.success(response.transactions))
                } catch {
                    print("❌ Error decoding transactions: \(error)")
                    if let body = String(data: data, encoding: .utf8) {
                        print("🧾 Raw response:\n\(body)")
                    }
                    completion(.failure(error))
                }
            } else {
                completion(.failure(error ?? URLError(.badServerResponse)))
            }
        }

        task.resume()
    }

}

