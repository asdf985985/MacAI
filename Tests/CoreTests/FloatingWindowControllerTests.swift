import XCTest
@testable import Core
import AppKit

final class FloatingWindowControllerTests: XCTestCase {
    func testWindowIsAlwaysOnTopAndClickThrough() {
        let controller = FloatingWindowController()
        guard let window = controller.window else {
            XCTFail("window should not be nil")
            return
        }
        XCTAssertTrue(window.ignoresMouseEvents, "Window should ignore mouse events (click-through)")
        XCTAssertEqual(window.level, .floating, "Window should be always-on-top (floating)")
    }

    func testSaveAndRestoreWindowFrame() {
        let controller = FloatingWindowController()
        guard let window = controller.window else {
            XCTFail("window should not be nil")
            return
        }
        let originalFrame = window.frame
        // 模拟移动窗口
        let newFrame = NSRect(x: 100, y: 100, width: 400, height: 300)
        window.setFrame(newFrame, display: false)
        controller.saveWindowFrame()
        // 恢复窗口
        window.setFrame(originalFrame, display: false)
        controller.restoreWindowFrame()
        XCTAssertEqual(window.frame, newFrame, "Window frame should be restored to saved value")
    }
} 