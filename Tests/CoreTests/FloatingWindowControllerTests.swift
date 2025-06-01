import XCTest
@testable import Core
import AppKit

final class FloatingWindowControllerTests: XCTestCase {
    var controller: FloatingWindowController!
    
    override func setUp() {
        super.setUp()
        controller = FloatingWindowController()
    }
    
    override func tearDown() {
        controller = nil
        super.tearDown()
    }
    
    func testWindowIsAlwaysOnTopAndClickThrough() {
        guard let window = controller.window else {
            XCTFail("window should not be nil")
            return
        }
        XCTAssertTrue(window.ignoresMouseEvents, "Window should ignore mouse events (click-through)")
        XCTAssertEqual(window.level, .floating, "Window should be always-on-top (floating)")
        XCTAssertTrue(window.collectionBehavior.contains(.canJoinAllSpaces), "Window should be visible on all spaces")
        XCTAssertTrue(window.collectionBehavior.contains(.stationary), "Window should be stationary")
    }

    func testSaveAndRestoreWindowFrame() {
        guard let window = controller.window else {
            XCTFail("window should not be nil")
            return
        }
        let originalFrame = window.frame
        let originalAlpha = window.alphaValue
        
        // 测试保存和恢复位置
        let newFrame = NSRect(x: 100, y: 100, width: 400, height: 300)
        window.setFrame(newFrame, display: false)
        controller.saveWindowFrame()
        
        // 测试保存和恢复透明度
        let newAlpha: CGFloat = 0.5
        window.alphaValue = newAlpha
        controller.saveWindowFrame()
        
        // 恢复窗口
        window.setFrame(originalFrame, display: false)
        window.alphaValue = originalAlpha
        controller.restoreWindowFrame()
        
        XCTAssertEqual(window.frame, newFrame, "Window frame should be restored to saved value")
        XCTAssertEqual(window.alphaValue, newAlpha, "Window alpha should be restored to saved value")
    }
    
    func testWindowVisibility() {
        guard let window = controller.window else {
            XCTFail("window should not be nil")
            return
        }
        
        // 初始状态应该是可见的
        XCTAssertTrue(window.isVisible, "Window should be visible initially")
        
        // 测试隐藏
        controller.toggleVisibility()
        XCTAssertFalse(window.isVisible, "Window should be hidden after toggle")
        
        // 测试显示
        controller.toggleVisibility()
        XCTAssertTrue(window.isVisible, "Window should be visible after second toggle")
    }
    
    func testWindowAlpha() {
        guard let window = controller.window else {
            XCTFail("window should not be nil")
            return
        }
        
        // 测试设置透明度
        let testAlpha: CGFloat = 0.5
        controller.setAlpha(testAlpha)
        XCTAssertEqual(window.alphaValue, testAlpha, "Window alpha should be set correctly")
        
        // 测试边界值
        controller.setAlpha(2.0) // 应该被限制为 1.0
        XCTAssertEqual(window.alphaValue, 1.0, "Window alpha should be capped at 1.0")
        
        controller.setAlpha(-1.0) // 应该被限制为 0.1
        XCTAssertEqual(window.alphaValue, 0.1, "Window alpha should be capped at 0.1")
    }
    
    func testMoveAndResizeModes() {
        guard let window = controller.window else {
            XCTFail("window should not be nil")
            return
        }
        
        // 测试移动模式
        controller.enterMoveMode()
        XCTAssertFalse(window.ignoresMouseEvents, "Window should not ignore mouse events in move mode")
        XCTAssertTrue(window.isMovableByWindowBackground, "Window should be movable by background in move mode")
        
        controller.exitMoveMode()
        XCTAssertTrue(window.ignoresMouseEvents, "Window should ignore mouse events after exiting move mode")
        XCTAssertFalse(window.isMovableByWindowBackground, "Window should not be movable by background after exiting move mode")
        
        // 测试调整大小模式
        controller.enterResizeMode()
        XCTAssertFalse(window.ignoresMouseEvents, "Window should not ignore mouse events in resize mode")
        XCTAssertFalse(window.isMovableByWindowBackground, "Window should not be movable by background in resize mode")
        
        controller.exitResizeMode()
        XCTAssertTrue(window.ignoresMouseEvents, "Window should ignore mouse events after exiting resize mode")
    }
} 