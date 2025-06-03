import XCTest
import Combine
import Foundation
@testable import Core

final class AIServiceTests: XCTestCase {
    var sut: AIService!
    var configManager: ConfigManager!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        configManager = ConfigManager()
        sut = AIService(configManager: configManager)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        configManager = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testProcessTextWithInvalidAPIKey() async throws {
        let mockSession = MockURLSession()
        let configManager = ConfigManager()
        let service = AIService(configManager: configManager, session: mockSession)
        // 不设置 API Key
        do {
            _ = try await service.generateSuggestion(for: "test", contextType: Core.ContextType.stt, previousContext: nil)
            XCTFail("Should throw error")
        } catch AIServiceError.invalidAPIKey {
            // 预期错误
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testProcessTextWithValidAPIKey() throws {
        let mockSession = MockURLSession()
        let json: [String: Any] = [
            "candidates": [[
                "content": [
                    "parts": [["text": "模拟AI回答"]]
                ]
            ]]
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        let response = HTTPURLResponse(url: URL(string: "https://test")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockSession.mockData = data
        mockSession.mockResponse = response
        let aiService = AIService(configManager: ConfigManager(), session: mockSession)
        try aiService.saveAPIKey("test-api-key")
        let expectation = XCTestExpectation(description: "Should receive result")
        aiService.resultPublisher
            .sink { result in
                XCTAssertFalse(result.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        aiService.processText("Test text")
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testProcessTextWithDifferentContextTypes() throws {
        let mockSession = MockURLSession()
        let json: [String: Any] = [
            "candidates": [[
                "content": [
                    "parts": [["text": "模拟AI回答"]]
                ]
            ]]
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        let response = HTTPURLResponse(url: URL(string: "https://test")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockSession.mockData = data
        mockSession.mockResponse = response
        let aiService = AIService(configManager: ConfigManager(), session: mockSession)
        try aiService.saveAPIKey("test-api-key")
        let expectation = XCTestExpectation(description: "Should process different context types")
        expectation.expectedFulfillmentCount = 3
        
        aiService.resultPublisher
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        aiService.processText("Test text", contextType: .stt)
        aiService.processText("Test text", contextType: .ocrSingle)
        aiService.processText("Test text", contextType: .ocrBatch)
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testProcessTextWithPreviousContext() throws {
        let mockSession = MockURLSession()
        let json: [String: Any] = [
            "candidates": [[
                "content": [
                    "parts": [["text": "模拟AI回答"]]
                ]
            ]]
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        let response = HTTPURLResponse(url: URL(string: "https://test")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockSession.mockData = data
        mockSession.mockResponse = response
        let aiService = AIService(configManager: ConfigManager(), session: mockSession)
        try aiService.saveAPIKey("test-api-key")
        let expectation = XCTestExpectation(description: "Should process text with previous context")
        
        aiService.resultPublisher
            .sink { result in
                XCTAssertFalse(result.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        let previousContext = ["Previous context 1", "Previous context 2"]
        aiService.processText("Test text", contextType: .stt, previousContext: previousContext)
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRetryMechanism() async throws {
        let mockSession = MockURLSession()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )
        mockSession.mockError = NSError(domain: "test", code: 500, userInfo: nil)
        let configManager = ConfigManager()
        let service = AIService(configManager: configManager, session: mockSession);
        do {
            _ = try await service.generateSuggestion(for: "test", contextType: Core.ContextType.stt, previousContext: nil)
            XCTFail("Should throw error")
        } catch AIServiceError.networkError {
            // 预期错误
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testAPIKeyManagement() throws {
        // 测试保存 API 密钥
        try sut.saveAPIKey("test-api-key")
        
        // 测试获取 API 密钥
        let apiKey = try sut.getAPIKey()
        XCTAssertEqual(apiKey, "test-api-key")
        
        // 测试更新 API 密钥
        try sut.saveAPIKey("new-api-key")
        let updatedApiKey = try sut.getAPIKey()
        XCTAssertEqual(updatedApiKey, "new-api-key")
    }
    
    func testPromptConfig() {
        let promptConfig = PromptConfig()
        
        // 测试 STT 提示词
        let sttPrompt = promptConfig.getPrompt(for: "test text", contextType: .stt, previousContext: nil)
        XCTAssertTrue(sttPrompt.contains("语音识别文本"))
        
        // 测试 OCR 单次提示词
        let ocrSinglePrompt = promptConfig.getPrompt(for: "test text", contextType: .ocrSingle, previousContext: nil)
        XCTAssertTrue(ocrSinglePrompt.contains("OCR识别的文本内容"))
        
        // 测试 OCR 批量提示词
        let ocrBatchPrompt = promptConfig.getPrompt(for: "test text", contextType: .ocrBatch, previousContext: nil)
        XCTAssertTrue(ocrBatchPrompt.contains("批量OCR识别的文本内容"))
        
        // 测试带上下文的提示词
        let contextPrompt = promptConfig.getPrompt(for: "test text", contextType: .stt, previousContext: ["context1", "context2"])
        XCTAssertTrue(contextPrompt.contains("历史上下文"))
        XCTAssertTrue(contextPrompt.contains("context1"))
        XCTAssertTrue(contextPrompt.contains("context2"))
    }
    
    func testMockSuccessResponse() async throws {
        let mockSession = MockURLSession()
        let json: [String: Any] = [
            "candidates": [[
                "content": [
                    "parts": [["text": "**AI回答**"]]
                ]
            ]]
        ]
        let data = try! JSONSerialization.data(withJSONObject: json)
        let response = HTTPURLResponse(url: URL(string: "https://test")!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        mockSession.mockData = data
        mockSession.mockResponse = response
        let aiService = AIService(configManager: ConfigManager(), session: mockSession)
        try aiService.saveAPIKey("mock-key")
        let result = try await aiService.generateSuggestion(for: "你好", contextType: Core.ContextType.stt, previousContext: nil as [String]?)
        XCTAssertTrue(result.contains("AI回答"))
    }

    func testMockNetworkError() async throws {
        let mockSession = MockURLSession()
        mockSession.mockError = URLError(.notConnectedToInternet)
        let aiService = AIService(configManager: ConfigManager(), session: mockSession)
        try aiService.saveAPIKey("mock-key")
        do {
            _ = try await aiService.generateSuggestion(for: "test", contextType: Core.ContextType.stt, previousContext: nil as [String]?)
            XCTFail("应抛出网络错误")
        } catch let error as AIServiceError {
            switch error {
            case .networkError(let underlying):
                XCTAssertTrue(underlying is URLError)
            default:
                XCTFail("错误类型不符")
            }
        }
    }

    func testMockAPIError() async throws {
        let mockSession = MockURLSession()
        let response = HTTPURLResponse(url: URL(string: "https://test")!, statusCode: 400, httpVersion: nil, headerFields: nil)!
        mockSession.mockData = Data()
        mockSession.mockResponse = response
        let aiService = AIService(configManager: ConfigManager(), session: mockSession)
        try aiService.saveAPIKey("mock-key")
        do {
            _ = try await aiService.generateSuggestion(for: "test", contextType: Core.ContextType.stt, previousContext: nil as [String]?)
            XCTFail("应抛出API错误")
        } catch let error as AIServiceError {
            switch error {
            case .apiError(let msg):
                XCTAssertTrue(msg.contains("400"))
            default:
                XCTFail("错误类型不符")
            }
        }
    }

    func testMockRateLimit() async throws {
        let mockSession = MockURLSession()
        let response = HTTPURLResponse(url: URL(string: "https://test")!, statusCode: 429, httpVersion: nil, headerFields: nil)!
        mockSession.mockData = Data()
        mockSession.mockResponse = response
        let aiService = AIService(configManager: ConfigManager(), session: mockSession)
        try aiService.saveAPIKey("mock-key")
        do {
            _ = try await aiService.generateSuggestion(for: "test", contextType: Core.ContextType.stt, previousContext: nil as [String]?)
            XCTFail("应抛出速率限制错误")
        } catch let error as AIServiceError {
            switch error {
            case .rateLimitExceeded:
                XCTAssertTrue(true)
            default:
                XCTFail("错误类型不符")
            }
        }
    }
} 