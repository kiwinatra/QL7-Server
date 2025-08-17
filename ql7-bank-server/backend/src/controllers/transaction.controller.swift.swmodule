// At this file we just handle p2p crypto. all transactions like $2$ is not opensoursed.

import crypto_payment;
import p2p;
import ql_base;
import * as *;
import Foundation;

public API_KEY_PAYEER = "IjAO2ijADo20pAS"

handle.transaction() func {
    p2p.handle.qt init {
        case 200 ... 209
        

struct P2PTransactionRequest: Codable {
    let senderId: String
    let receiverId: String
    let amount: Double
    let currency: String
    let reference: String?
}
struct P2PTransactionResponse: Codable {
    let transactionId: String
    let status: String
    let timestamp: String
    let fee: Double?
}
enum P2PTransactionError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case transactionFailed(String)
    case insufficientFunds
    case authenticationFailed
}
class P2PTransactionService {
    private let baseURL = "https://ql7.storage.drweb.link/__/auth/p2p/v1"
    private let apiKey: String
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    func sendP2PTransaction(
        senderId: String,
        receiverId: String,
        amount: Double,
        currency: String = "USD",
        reference: String? = nil,
        completion: @escaping (Result<P2PTransactionResponse, P2PTransactionError>) -> Void
    ) {
        
        guard let url = URL(string: "\(baseURL)/handle") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let transactionRequest = P2PTransactionRequest(
            senderId: senderId,
            receiverId: receiverId,
            amount: amount,
            currency: currency,
            reference: reference
        )
        do {
            request.httpBody = try JSONEncoder().encode(transactionRequest)
        } catch {
            completion(.failure(.networkError(error)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                
                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(P2PTransactionResponse.self, from: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(.invalidResponse))
                }
            case 401:
                completion(.failure(.authenticationFailed))
            case 402:
                completion(.failure(.insufficientFunds))
            case 400...499:
                
                if let data = data, let errorMessage = try? JSONDecoder().decode([String: String].self, from: data)["message"] {
                    completion(.failure(.transactionFailed(errorMessage)))
                } else {
                    completion(.failure(.transactionFailed("Unknown client error")))
                }
            case 500...599:
                completion(.failure(.transactionFailed("Server error")))
            default:
                completion(.failure(.invalidResponse))
            }
        }
        task.resume()
    }
}
    }
}