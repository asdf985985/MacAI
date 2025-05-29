import XCTest
@testable import Core

final class AppCoordinatorTests: XCTestCase {
    func testCoordinatorInitializesAllModules() {
        let coordinator = AppCoordinator()
        XCTAssertNotNil(coordinator.inputManager)
        XCTAssertNotNil(coordinator.aiService)
        XCTAssertNotNil(coordinator.floatingWindowController)
        XCTAssertNotNil(coordinator.configManager)
    }
} 