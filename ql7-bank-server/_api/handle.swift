import Foundation
import Security
import CommonCrypto

protocol BankAPIHandlerDelegate: AnyObject {
    func didCompleteTransaction(result: Result<BankTransaction, BankAPIError>)
    func didUpdateBalance(newBalance: Double)
    func didReceiveSecurityChallenge()
}

enum BankAPIError: Error {
    case authenticationFailed
    case invalidRequest
    case insufficientFunds
    case serverError
    case networkError
    case securityBreachAttempt
    case sessionExpired
    case biometricVerificationFailed
}

struct BankTransaction: Codable {
    let id: UUID
    let amount: Double
    let currency: String
    let recipient: String
    let timestamp: Date
    let status: TransactionStatus
    let verificationLevel: VerificationLevel
}

enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
    case reversed
}

enum VerificationLevel: Int, Codable {
    case none = 0
    case sms = 1
    case biometric = 2
    case hardwareToken = 3
}

class BankAPIHandler {
    private let baseURL = URL(string: "https://qt7.secure.drweb.link/__/v1")!
    private let session: URLSession
    private let pinProtector: PinProtector
    private let jwtHandler: JWTHandler
    private let requestSigner: RequestSigner
    private var sessionToken: String?
    private var refreshToken: String?
    private var transactionCache: [UUID: BankTransaction] = [:]
    
    weak var delegate: BankAPIHandlerDelegate?
    
    init() {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses?.insert(BankSecurityProtocol.self, at: 0)
        self.session = URLSession(configuration: config)
        self.pinProtector = PinProtector()
        self.jwtHandler = JWTHandler()
        self.requestSigner = RequestSigner()
    }
    
    // MARK: - Authentication
    
    func authenticateWithBiometrics(completion: @escaping (Result<Void, BankAPIError>) -> Void) {
        let endpoint = baseURL.appendingPathComponent("/auth/biometric")
        
        BiometricAuthenticator.authenticate { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                var request = URLRequest(url: endpoint)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                
                let task = self.session.dataTask(with: request) { data, response, error in
                    self.handleAuthResponse(data: data, response: response, error: error, completion: completion)
                }
                task.resume()
                
            case .failure:
                completion(.failure(.biometricVerificationFailed))
            }
        }
    }
    
    private func handleAuthResponse(data: Data?, response: URLResponse?, error: Error?, 
                                   completion: @escaping (Result<Void, BankAPIError>) -> Void) {
        if let error = error {
            logSecurityEvent("Auth error: \(error.localizedDescription)")
            completion(.failure(.networkError))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            completion(.failure(.invalidRequest))
            return
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            guard let data = data,
                  let authResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) else {
                completion(.failure(.serverError))
                return
            }
            
            self.sessionToken = authResponse.sessionToken
            self.refreshToken = authResponse.refreshToken
            KeychainManager.storeToken(authResponse.sessionToken, for: .session)
            KeychainManager.storeToken(authResponse.refreshToken, for: .refresh)
            completion(.success(()))
            
        case 401:
            completion(.failure(.authenticationFailed))
            
        case 403:
            logSecurityEvent("Possible security breach attempt")
            completion(.failure(.securityBreachAttempt))
            
        default:
            completion(.failure(.serverError))
        }
    }
    
    // MARK: - Transaction Handling
    
    func performTransaction(_ transaction: TransactionRequest, 
                           verification: VerificationLevel = .sms) {
        guard let sessionToken = sessionToken else {
            delegate?.didCompleteTransaction(result: .failure(.sessionExpired))
            return
        }
        
        let endpoint = baseURL.appendingPathComponent("/transactions")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")
        
        do {
            let signedRequest = try requestSigner.signRequest(request, with: transaction)
            request.httpBody = signedRequest.httpBody
            
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                self?.handleTransactionResponse(data: data, response: response, error: error)
            }
            task.resume()
        } catch {
            delegate?.didCompleteTransaction(result: .failure(.invalidRequest))
        }
    }
    
    private func handleTransactionResponse(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            logNetworkError(error)
            delegate?.didCompleteTransaction(result: .failure(.networkError))
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            delegate?.didCompleteTransaction(result: .failure(.invalidRequest))
            return
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            guard let data = data,
                  let transaction = try? JSONDecoder().decode(BankTransaction.self, from: data) else {
                delegate?.didCompleteTransaction(result: .failure(.serverError))
                return
            }
            
            transactionCache[transaction.id] = transaction
            delegate?.didCompleteTransaction(result: .success(transaction))
            
        case 401:
            delegate?.didCompleteTransaction(result: .failure(.sessionExpired))
            
        case 402:
            delegate?.didCompleteTransaction(result: .failure(.insufficientFunds))
            
        case 403:
            logSecurityEvent("Transaction security breach attempt")
            delegate?.didCompleteTransaction(result: .failure(.securityBreachAttempt))
            
        default:
            delegate?.didCompleteTransaction(result: .failure(.serverError))
        }
    }
    
    // MARK: - Security
    
    private func logSecurityEvent(_ message: String) {
        SecurityLogger.logEvent(message)
        if message.contains("breach") {
            delegate?.didReceiveSecurityChallenge()
        }
    }
    
    private func logNetworkError(_ error: Error) {
        NSLog("Network error: \(error.localizedDescription)")
    }
}

// MARK: - Security Utilities

class PinProtector {
    private let maxAttempts = 3
    private var attempts = 0
    
    func verifyPin(_ pin: String, completion: @escaping (Bool) -> Void) {
        guard pin.count == 6, pin.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else {
            completion(false)
            return
        }
        
        attempts += 1
        if attempts >= maxAttempts {
            completion(false)
            BankAPIHandler.notifySecurityTeam()
            return
        }
        
        KeychainManager.verifyPin(pin) { success in
            if success {
                self.attempts = 0
            }
            completion(success)
        }
    }
}

class JWTHandler {
    func validate(jwt: String) -> Bool {
        
        return true
    }
}

class RequestSigner {
    func signRequest(_ request: URLRequest, with data: Encodable) throws -> URLRequest {
        var signedRequest = request
        let jsonData = try JSONEncoder().encode(data)
        let signature = try SecurityManager.signData(jsonData)
        signedRequest.setValue(signature, forHTTPHeaderField: "X-Request-Signature")
        signedRequest.httpBody = jsonData
        return signedRequest
    }
}

// MARK: - Security Protocol

class BankSecurityProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url else { return false }
        return url.host?.contains("bankapi.example.com") ?? false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        // Implement certificate pinning and other security checks
        guard let client = client else { return }
        
        if SecurityManager.validateRequest(request) {
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                
                if let error = error {
                    client.urlProtocol(self, didFailWithError: error)
                    return
                }
                
                if let response = response {
                    client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                
                if let data = data {
                    client.urlProtocol(self, didLoad: data)
                }
                
                client.urlProtocolDidFinishLoading(self)
            }
            task.resume()
        } else {
            let error = NSError(domain: "BankSecurity", code: -1, userInfo: nil)
            client.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {
        nil,
    }
}