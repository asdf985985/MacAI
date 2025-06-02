import XCTest
import HotKey
@testable import UI
import Core

final class HotkeyManagerTests: XCTestCase {
    var hotkeyManager: HotkeyManager!
    var floatingWindowController: FloatingWindowController!
    var configManager: ConfigManager!
    var sttManager: STTManager!
    var inputManager: InputManager!

    override func setUp() {
        super.setUp()
        configManager = ConfigManager()
        sttManager = STTManager()
        inputManager = InputManager(configManager: configManager)
        floatingWindowController = FloatingWindowController(sttManager: sttManager)
        hotkeyManager = HotkeyManager(floatingWindowController: floatingWindowController, configManager: configManager, sttManager: sttManager, inputManager: inputManager)
    }

    override func tearDown() {
        hotkeyManager = nil
        floatingWindowController = nil
        configManager = nil
        sttManager = nil
        inputManager = nil
        super.tearDown()
    }

    func testHotkeyRegistration() {
        // 验证热键是否已注册（示例：批量模式开关热键）
        XCTAssertNotNil(hotkeyManager.batchToggleHotKey)
        // 验证热键动作分发（示例：模拟热键触发）
        hotkeyManager.batchToggleHotKey?.keyDownHandler?()
        // 验证批量模式状态变化（需通过InputManager验证）
        XCTAssertTrue(inputManager.isBatchMode)
    }
} 