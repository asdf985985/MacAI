import XCTest
import Combine
@testable import Input

final class InputManagerTests: XCTestCase {
    var inputManager: InputManager!
    var configManager: ConfigManager!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        configManager = ConfigManager()
        inputManager = InputManager(configManager: configManager)
        cancellables = []
    }

    override func tearDown() {
        inputManager = nil
        configManager = nil
        cancellables = nil
        super.tearDown()
    }

    func testToggleBatchMode() {
        XCTAssertFalse(inputManager.isBatchMode)
        inputManager.toggleBatchMode()
        XCTAssertTrue(inputManager.isBatchMode)
        inputManager.toggleBatchMode()
        XCTAssertFalse(inputManager.isBatchMode)
    }

    func testAddOCRToBatch() {
        inputManager.toggleBatchMode()
        inputManager.addOCRToBatch("Test OCR 1")
        inputManager.addOCRToBatch("Test OCR 2")
        // 验证批量提交
        let expectation = XCTestExpectation(description: "Batch sent")
        inputManager.textPublisher.sink { text in
            XCTAssertEqual(text, "Test OCR 1\nTest OCR 2")
            expectation.fulfill()
        }.store(in: &cancellables)
        inputManager.finalizeBatch()
        wait(for: [expectation], timeout: 1.0)
    }
} 