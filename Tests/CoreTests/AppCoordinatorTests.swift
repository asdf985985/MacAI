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
    
    func testDataFlowFromInputToAI() {
        let expectation = XCTestExpectation(description: "AI should receive input")
        
        coordinator.aiService.resultPublisher
            .sink { result in
                XCTAssertEqual(result, "处理结果: Test Input")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        coordinator.inputManager.processInput("Test Input")
        wait(for: [expectation], timeout: 1.0)
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