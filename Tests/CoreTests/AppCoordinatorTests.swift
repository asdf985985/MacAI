import XCTest
import Combine
@testable import Core

final class AppCoordinatorTests: XCTestCase {
    var coordinator: AppCoordinator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        coordinator = AppCoordinator()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        coordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testCoordinatorInitializesAllModules() {
        XCTAssertNotNil(coordinator.inputManager)
        XCTAssertNotNil(coordinator.aiService)
        XCTAssertNotNil(coordinator.floatingWindowController)
        XCTAssertNotNil(coordinator.configManager)
    }
    
    @MainActor
    func testDataFlowFromInputToAI() async throws {
        let mockSession = MockURLSession()
        mockSession.mockResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )
        mockSession.mockData = """
        {
            "choices": [
                {
                    "text": "Mock response"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let configManager = ConfigManager()
        let coordinator = AppCoordinator()
        let expectation = XCTestExpectation(description: "AI should receive input")
        
        Task {
            do {
                let result = try await coordinator.aiService.processText("test input", contextType: Core.ContextType.stt)
                XCTAssertNotNil(result)
                expectation.fulfill()
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 0.5)
    }
    
    func testConfigManagerStoresAndRetrievesValues() {
        // 测试 API Key
        coordinator.configManager.apiKey = "test-api-key"
        XCTAssertEqual(coordinator.configManager.apiKey, "test-api-key")
        
        // 测试热键
        coordinator.configManager.hotkey = "⌘⇧B"
        XCTAssertEqual(coordinator.configManager.hotkey, "⌘⇧B")
    }
} 