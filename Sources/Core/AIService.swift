import Foundation
import Combine
import Security

// MARK: - URLSessionProtocol for Dependency Injection
public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

public enum AIServiceError: Error {
    case invalidAPIKey
    case networkError(Error)
    case apiError(String)
    case invalidResponse
    case rateLimitExceeded
    case timeout
    case keychainError(OSStatus)
}

public enum ContextType: String {
    case stt = "stt"
    case ocrSingle = "ocr_single"
    case ocrBatch = "ocr_batch"
}

public class AIService {
    private let configManager: ConfigManager
    private let promptConfig: PromptConfig
    private let resultSubject = PassthroughSubject<String, Never>()
    private let errorSubject = PassthroughSubject<AIServiceError, Never>()
    private let session: URLSessionProtocol
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"
    private var retryCount = 0
    private let maxRetries = 3
    private let keychainService = "com.macai.apikey"
    private let keychainAccount = "gemini-api-key"
    
    public var resultPublisher: AnyPublisher<String, Never> {
        resultSubject.eraseToAnyPublisher()
    }
    
    public var errorPublisher: AnyPublisher<AIServiceError, Never> {
        errorSubject.eraseToAnyPublisher()
    }
    
    public init(configManager: ConfigManager, session: URLSessionProtocol? = nil) {
        self.configManager = configManager
        self.promptConfig = PromptConfig()
        if let session = session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = 30
            config.timeoutIntervalForResource = 300
            self.session = URLSession(configuration: config)
        }
    }
    
    public func processText(_ text: String, contextType: ContextType = .stt, previousContext: [String]? = nil) {
        Task {
            do {
                let suggestion = try await generateSuggestion(for: text, contextType: contextType, previousContext: previousContext)
                resultSubject.send(suggestion)
            } catch {
                errorSubject.send(error as? AIServiceError ?? .apiError(error.localizedDescription))
            }
        }
    }
    
    public func generateSuggestion(for text: String, contextType: ContextType, previousContext: [String]?) async throws -> String {
        do {
            let apiKey = try getAPIKey()
            if apiKey.isEmpty {
                throw AIServiceError.invalidAPIKey
            }
            
            let prompt = promptConfig.getPrompt(for: text, contextType: contextType, previousContext: previousContext)
            let requestBody = createRequestBody(prompt: prompt)
            
            guard let url = URL(string: "\(baseURL)?key=\(apiKey)") else {
                throw AIServiceError.invalidResponse
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            do {
                let (data, response) = try await session.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw AIServiceError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200:
                    return try parseResponse(data)
                case 429:
                    throw AIServiceError.rateLimitExceeded
                case 500...599:
                    if retryCount < maxRetries {
                        retryCount += 1
                        try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                        return try await generateSuggestion(for: text, contextType: contextType, previousContext: previousContext)
                    }
                    throw AIServiceError.networkError(NSError(domain: "", code: httpResponse.statusCode))
                default:
                    throw AIServiceError.apiError("\(httpResponse.statusCode)")
                }
            } catch {
                if retryCount < maxRetries {
                    retryCount += 1
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                    return try await generateSuggestion(for: text, contextType: contextType, previousContext: previousContext)
                }
                if let aiError = error as? AIServiceError {
                    throw aiError
                }
                throw AIServiceError.networkError(error)
            }
        } catch AIServiceError.keychainError(let status) {
            print("[AIService] keychainError status:", status, "errSecItemNotFound:", errSecItemNotFound)
            if status == errSecItemNotFound || Int(status) == Int(errSecItemNotFound) {
                throw AIServiceError.invalidAPIKey
            } else {
                throw AIServiceError.keychainError(status)
            }
        } catch {
            throw error
        }
    }
    
    private func createRequestBody(prompt: String) -> [String: Any] {
        return [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.7,
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 1024
            ]
        ]
    }
    
    private func parseResponse(_ data: Data) throws -> String {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw AIServiceError.invalidResponse
        }
        
        // 解析 Markdown 响应
        do {
            return try MarkdownParser.parse(text)
        } catch {
            // 如果 Markdown 解析失败，返回原始文本
            return text
        }
    }
    
    // MARK: - Keychain Management
    
    func getAPIKey() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecItemNotFound {
            throw AIServiceError.invalidAPIKey
        }
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let apiKey = String(data: data, encoding: .utf8) else {
            throw AIServiceError.keychainError(status)
        }
        
        return apiKey
    }
    
    public func saveAPIKey(_ apiKey: String) throws {
        guard let data = apiKey.data(using: .utf8) else {
            throw AIServiceError.invalidAPIKey
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: keychainService,
                kSecAttrAccount as String: keychainAccount
            ]
            
            let updateAttributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, updateAttributes as CFDictionary)
            guard updateStatus == errSecSuccess else {
                throw AIServiceError.keychainError(updateStatus)
            }
        } else if status != errSecSuccess {
            throw AIServiceError.keychainError(status)
        }
    }
} 